<template>
  <el-container class="header-container is-dark">
    <div class="logo">
      <a href="http://aeeis.cn" class="logo_link">
        <img
          class="logo_img"
          src="http://aeeis.cn/static/img/logo-white.png"
          height="50"
          width="50"
        />
      </a>
    </div>
    <div class="dropdowns">
      <el-dropdown>
        <span class="el-dropdown-link">
          文件<i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item @click.native="refClick">
            <i class="el-icon-upload2"></i>
            导入 .md
            <input hidden type="file" ref="fileInput" accept=".md" />
          </el-dropdown-item>
          <el-dropdown-item @click.native="$emit('download')">
            <i class="el-icon-download"></i>
            导出 .md
          </el-dropdown-item>
          <el-dropdown-item @click.native="$emit('export')">
            <i class="el-icon-document"></i>
            导出 .html
          </el-dropdown-item>
          <el-dropdown-item divided @click.native="themeChanged">
            <i
              class="el-icon-check"
              :style="{ opacity: nightMode ? 1 : 0 }"
            ></i>
            暗黑模式
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
      <el-dropdown>
        <span class="el-dropdown-link">
          格式<i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item
            class="format-item"
            v-for="{ label, kbd, emitArgs } in formatItems"
            :key="kbd"
            @click.native="$emit(...emitArgs)"
          >
            {{ label }}
            <kbd>{{ kbd }}</kbd>
          </el-dropdown-item>
          <el-dropdown-item divided @click.native="statusChanged">
            <i
              class="el-icon-check"
              :style="{ opacity: citeStatus ? 1 : 0 }"
            ></i>
            微信外链转底部引用
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
      <el-dropdown>
        <span class="el-dropdown-link">
          编辑<i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item @click.native="$emit('show-dialog-upload-img')">
            <i class="el-icon-upload"></i>
            上传图片
          </el-dropdown-item>
          <el-dropdown-item @click.native="$emit('show-dialog-form')">
            <i class="el-icon-s-grid"></i>
            插入表格
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
      <el-dropdown>
        <span class="el-dropdown-link">
          样式<i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item class="padding-left-3">
            <style-option-menu
              label="字体"
              :options="config.builtinFonts"
              :current="selectFont"
              :charge="fontChanged"
            ></style-option-menu>
          </el-dropdown-item>
          <el-dropdown-item class="padding-left-3">
            <style-option-menu
              label="字号"
              :options="config.sizeOption"
              :current="selectSize"
              :charge="sizeChanged"
            ></style-option-menu>
          </el-dropdown-item>
          <el-dropdown-item class="padding-left-3">
            <style-option-menu
              label="颜色"
              :options="config.colorOption"
              :current="selectColor"
              :charge="colorChanged"
            ></style-option-menu>
          </el-dropdown-item>
          <el-dropdown-item class="padding-left-3">
            <style-option-menu
              label="代码主题"
              :options="config.codeThemeOption"
              :current="selectCodeTheme"
              :charge="codeThemeChanged"
            ></style-option-menu>
          </el-dropdown-item>
          <el-dropdown-item
            divided
            class="padding-left-3"
            @click.native="showPicker()"
          >
            自定义颜色
            <el-color-picker
              show-alpha
              ref="colorPicker"
              size="mini"
              style="float: right; margin-top: 3px"
              v-model="selectColor"
              @change="colorChanged"
            ></el-color-picker>
          </el-dropdown-item>
          <el-dropdown-item class="padding-left-3" @click.native="customStyle">
            自定义 CSS
          </el-dropdown-item>
          <el-dropdown-item divided @click.native="codeBlockChanged">
            <i
              class="el-icon-check"
              :style="{ opacity: isMacCodeBlock ? 1 : 0 }"
            ></i>
            Mac 代码块
          </el-dropdown-item>
          <el-dropdown-item
            divided
            class="padding-left-3"
            @click.native="showResetConfirm = true"
          >
            重置
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
      <el-dropdown>
        <span class="el-dropdown-link">
          帮助<i class="el-icon-arrow-down el-icon--right"></i>
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item @click.native="$emit('show-about-dialog')">
            关于
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
    <el-button plain size="medium" :type="btnType" @click="copy">
      复制
    </el-button>
    <el-button plain size="medium" :type="btnType" @click="prePost">
      发布
    </el-button>

    <post-info-dialog
      :form="form"
      @post="post"
      @close="form.dialogVisible = false"
    >
    </post-info-dialog>
    <reset-dialog
      :show-reset-confirm="showResetConfirm"
      @confirm="confirmReset"
      @close="cancelReset"
    ></reset-dialog>
  </el-container>
</template>

<script>
import { mapState, mapActions } from 'pinia'
import { useStore } from '@/stores'

import { setFontSize, setColorWithCustomTemplate } from '@/assets/scripts/util'
import { solveWeChatImage, mergeCss } from '@/assets/scripts/converter'
import DEFAULT_CSS_CONTENT from '@/assets/example/theme-css.txt'
import config from '@/assets/scripts/config'
import ResetDialog from './ResetDialog'
import StyleOptionMenu from './StyleOptionMenu'
import PostInfoDialog from './PostInfoDialog'

export default {
  name: `editor-header`,
  data() {
    return {
      config,
      citeStatus: false,
      isMacCodeBlock: true,
      showResetConfirm: false,
      selectFont: ``,
      selectSize: ``,
      selectColor: ``,
      selectCodeTheme: config.codeThemeOption[2].value,
      form: {
        dialogVisible: false,
        title: ``,
        desc: ``,
        thumb: ``,
        content: ``,
      },
      formatItems: [
        {
          label: `加粗`,
          kbd: `Ctrl/Command + B`,
          emitArgs: [`addFormat`, `**`],
        },
        {
          label: `斜体`,
          kbd: `Ctrl/Command + I`,
          emitArgs: [`addFormat`, `*`],
        },
        {
          label: `删除线`,
          kbd: `Ctrl/Command + D`,
          emitArgs: [`addFormat`, `~~`],
        },
        {
          label: `超链接`,
          kbd: `Ctrl/Command + K`,
          emitArgs: [`addFormat`, `[`, `]()`],
        },
        {
          label: `格式化`,
          kbd: `Ctrl/Command + F`,
          emitArgs: [`formatContent`],
        },
      ],
    }
  },
  components: {
    PostInfoDialog,
    StyleOptionMenu,
    ResetDialog,
  },
  computed: {
    btnType() {
      return this.nightMode ? `default` : `primary`
    },
    ...mapState(useStore, {
      output: (state) => state.output,
      editor: (state) => state.editor,
      cssEditor: (state) => state.cssEditor,
      currentFont: (state) => state.currentFont,
      currentSize: (state) => state.currentSize,
      currentColor: (state) => state.currentColor,
      codeTheme: (state) => state.codeTheme,
      nightMode: (state) => state.nightMode,
      currentCiteStatus: (state) => state.citeStatus,
      currentIsMacCodeBlock: (state) => state.isMacCodeBlock,
    }),
  },
  methods: {
    refClick() {
      this.$refs.fileInput.click()
    },
    showPicker() {
      this.$refs.colorPicker.showPicker = true
    },
    prePost() {
      let auto = {}
      try {
        auto = {
          thumb: document.querySelector(`#output img`).src,
          title: [1, 2, 3, 4, 5, 6]
            .map((h) => document.querySelector(`#output h${h}`))
            .filter((h) => h)[0].innerText,
          desc: document.querySelector(`#output p`).innerText,
          content: this.output,
        }
      } catch (error) {
        console.log(`error`, error)
      }
      this.form = {
        dialogVisible: true,
        ...auto,
        auto,
      }
    },
    post() {
      this.form.dialogVisible = false
      // 使用 window.$syncer 可以检测是否安装插件
      window.syncPost({
        title: this.form.title || this.form.auto.title,
        desc: this.form.desc || this.form.auto.desc,
        content: this.form.content || this.form.auto.content,
        thumb: this.form.thumb || this.form.auto.thumb,
      })
    },
    fontChanged(fonts) {
      this.setWxRendererOptions({
        fonts: fonts,
      })
      this.setCurrentFont(fonts)
      this.selectFont = fonts
      this.$emit(`refresh`)
    },
    sizeChanged(size) {
      let theme = setFontSize(size.replace(`px`, ``))
      theme = setColorWithCustomTemplate(theme, this.currentColor)
      this.setWxRendererOptions({
        size: size,
        theme: theme,
      })
      this.setCurrentSize(size)
      this.selectSize = size
      this.$emit(`refresh`)
    },
    colorChanged(color) {
      let theme = setFontSize(this.currentSize.replace(`px`, ``))

      theme = setColorWithCustomTemplate(theme, color)
      this.setWxRendererOptions({
        theme: theme,
      })
      this.setCurrentColor(color)
      this.selectColor = color
      this.$emit(`refresh`)
    },
    codeThemeChanged(theme) {
      this.setCurrentCodeTheme(theme)
      this.selectCodeTheme = theme
      this.$emit(`refresh`)
    },
    statusChanged() {
      this.citeStatus = !this.citeStatus
      this.setCiteStatus(this.citeStatus)
      this.$emit(`refresh`)
    },
    codeBlockChanged() {
      this.isMacCodeBlock = !this.isMacCodeBlock
      this.setIsMacCodeBlock(this.isMacCodeBlock)
      this.$emit(`refresh`)
    },
    // 复制到微信公众号
    copy() {
      this.$emit(`startCopy`)
      setTimeout(() => {
        solveWeChatImage()

        const clipboardDiv = document.getElementById(`output`)
        clipboardDiv.innerHTML = mergeCss(clipboardDiv.innerHTML)

        // 调整 katex 公式元素为行内标签，目的是兼容微信公众号渲染
        clipboardDiv.innerHTML = clipboardDiv.innerHTML
          .replace(
            /class="base"( style="display: inline")*/g,
            `class="base" style="display: inline"`
          )
          // 公众号不支持 position， 转换为等价的 translateY
          .replace(/top:(.*?)em/g, `transform: translateY($1em)`)

        if (this.isMacCodeBlock) {
          clipboardDiv.innerHTML = clipboardDiv.innerHTML.replaceAll(
            /(<code class="prettyprint[^>]*)(style=")/g,
            `$1style="font-family: Menlo, 'Operator Mono', Consolas, Monaco, monospace;`
          )
        }
        clipboardDiv.focus()
        window.getSelection().removeAllRanges()
        let range = document.createRange()

        range.setStartBefore(clipboardDiv.firstChild)
        range.setEndAfter(clipboardDiv.lastChild)
        window.getSelection().addRange(range)
        document.execCommand(`copy`)
        window.getSelection().removeAllRanges()
        clipboardDiv.innerHTML = this.output
        // 输出提示
        this.$notify({
          showClose: true,
          message: `已复制渲染后的文章到剪贴板，可直接到公众号后台粘贴`,
          offset: 80,
          duration: 1600,
          type: `success`,
        })
        this.$emit(`refresh`)
        this.$emit(`endCopy`)
      }, 350)
    },
    // 自定义CSS样式
    async customStyle() {
      this.$emit(`showCssEditor`)
      this.$nextTick(() => {
        if (!this.cssEditor) {
          this.cssEditor.refresh()
        }
      })
      setTimeout(() => {
        this.cssEditor.refresh()
      }, 50)

      let flag = localStorage.getItem(`__css_content`)
      if (!flag) {
        this.setCssEditorValue(DEFAULT_CSS_CONTENT)
      }
    },
    // 重置样式
    confirmReset() {
      this.showResetConfirm = false
      localStorage.clear()
      this.cssEditor.setValue(DEFAULT_CSS_CONTENT)
      this.citeStatus = false
      this.statusChanged(false)
      this.fontChanged(this.config.builtinFonts[0].value)
      this.colorChanged(this.config.colorOption[0].value)
      this.sizeChanged(this.config.sizeOption[2].value)
      this.codeThemeChanged(this.config.codeThemeOption[2].value)
      this.$emit(`cssChanged`)
      this.selectFont = this.currentFont
      this.selectSize = this.currentSize
      this.selectColor = this.currentColor
      this.selectCodeTheme = this.codeTheme

      this.isMacCodeBlock = false
      this.codeBlockChanged()
    },
    cancelReset() {
      this.showResetConfirm = false
      this.editor.focus()
    },
    ...mapActions(useStore, [
      `setCurrentColor`,
      `setCiteStatus`,
      `themeChanged`,
      `setCurrentFont`,
      `setCurrentSize`,
      `setCssEditorValue`,
      `setCurrentCodeTheme`,
      `setWxRendererOptions`,
      `setIsMacCodeBlock`,
    ]),
  },
  mounted() {
    this.selectFont = this.currentFont
    this.selectSize = this.currentSize
    this.selectColor = this.currentColor
    this.selectCodeTheme = this.codeTheme
    this.citeStatus = this.currentCiteStatus
    this.isMacCodeBlock = this.currentIsMacCodeBlock

    const fileInput = this.$refs.fileInput
    fileInput.onchange = () => {
      const file = fileInput.files[0]
      if (file == null) {
        return
      }
      const read = new FileReader()
      read.readAsText(file)
      read.onload = () => {
        this.$emit(`import-md`, read.result)
      }
    }
  },
}
</script>

<style lang="less" scoped>
.header-container {
  padding: 10px 20px;
  align-items: center;
}

.dropdowns {
  flex: 1;
}

.el-dropdown {
  margin: 0 10px;
}

.el-dropdown-link {
  cursor: pointer;
  font-size: 18px;
  color: #fff;
}

.padding-left-3 {
  padding-left: 3em;
}

// 添加边距影响了 divided 行的移入效果，此处做一个兼容处理
.el-dropdown-menu__item--divided.padding-left-3 {
  position: relative;

  &::after {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    width: 3em;
    height: 6px;
    background: white;
  }
}

.format-item {
  .padding-left-3;
  width: 180px;

  kbd {
    font-size: 0.75em;
    float: right;
    color: #666;
  }
}
</style>
