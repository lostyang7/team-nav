/*
 * @author tuituidan
 * @date 2023/11/24
 */
export default {
  name: "card-edit-index",
  components: {
    'category-select': () => import('@/components/category-select/index.vue'),
    'card-icon-select': () => import('@/components/card-icon-select/index.vue'),
    'file-uploader': () => import('@/components/file-uploader/index.vue'),
    'card-http-builder': () => import('@/components/card-http-builder/index.vue'),
    'card-sql-builder': () => import('@/components/card-sql-builder/index.vue'),
  },
  props: {
    apply: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      show: false,
      showFaviconLoading: false,
      // 菜单树选项
      categoryOptions: [],
      // 表单参数
      form: {
        type: 'default',
        category: '',
        title: '',
        content: '',
        privateContent: '',
        url: '',
        showQrcode: false,
        icon: null,
        zip: null,
        dynamicBuilder: null,
        attachmentIds: [],
        attachments: [],
      },
      // 表单校验
      rules: {
        category: [
          {required: true, message: "所属分类不能为空", trigger: "blur"}
        ],
        title: [
          {required: true, message: "标题不能为空", trigger: "blur"}
        ],
        dynamicBuilder: [
          {required: true, message: '动态构建内容不能为空'}
        ],
        zip: [
          {required: true, message: '请上传网站zip文件'}
        ],
      },
      saveOption: {
        saveNotClear: false,
        saveKeepAdd: false,
      },
    }
  },
  methods: {
    open(item = {}) {
      this.resetForm();
      if (item.id) {
        this.title = this.apply ? '审核卡片' : '编辑卡片';
        this.form = {...item};
        this.form.attachmentIds = Array.isArray(this.form.attachments)
          ? this.form.attachments.map(item => item.id) : [];
      } else if (item.category) {
        this.form = {...item};
        this.title = '新增卡片';
      } else {
        this.title = '申请卡片';
        // 检查URL参数，如果是浏览器插件传递的参数，则自动填充
        this.checkUrlParams();
      }
      console.log(JSON.stringify(this.form))
      console.log(JSON.stringify(item))
      this.show = true;
      this.$nextTick(() => {
        this.$refs.refCategory.init();
        this.$refs.refCardIcon.init(this.form.icon);
      })
    },
    resetForm() {
      this.form = {
        type: 'default',
        category: '',
        title: '',
        content: '',
        privateContent: '',
        url: '',
        showQrcode: false,
        icon: null,
        zip: null,
        attachmentIds: [],
        attachments: [],
      };
      this.$nextTick(() => {
        this.$refs.form.clearValidate();
      })
    },
    zipFileChange(fileList) {
      if (fileList.length <= 0) {
        this.form.zip = null;
      } else {
        this.form.zip = {...fileList[0], isNew: true};
        this.$refs.form.validateField('zip');
      }
    },
    attachmentChange(fileList) {
      this.form.attachmentIds = Array.isArray(fileList)
        ? fileList.map(item => item.path) : [];
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs.form.validate(valid => {
        if (valid) {
          const newZip = this.form.type === 'zip' && this.form.zip && this.form.zip.isNew;
          if (newZip) {
            this.$modal.loading('压缩包解压时间较长，请耐心等待...');
          }
          if (!this.form.icon) {
            this.form.icon = {
              text: this.form.title.substr(0, 2),
              color: this.$refs.refCardIcon.getRandomColor(),
            };
          }
          if (!this.form.content && !this.form.type.startsWith('dynamic')) {
            this.form.content = this.form.url || this.form.title;
          }

          this.$http.save('/api/v1/card', {...this.form}, {timeout: 300000})
            .then(() => {
              this.$modal.msgSuccess('保存成功');
              if (this.form.id) {
                this.show = false;
              } else {
                this.show = this.saveOption.saveKeepAdd;
                if (!this.saveOption.saveNotClear) {
                  this.form.title = '';
                  this.form.content = '';
                  this.form.privateContent = '';
                  this.form.showQrcode = false;
                  this.form.zip = null;
                  this.form.dynamicBuilder = null;
                  this.form.attachmentIds = [];
                  this.form.attachments = [];
                }
              }
              this.$emit('refresh', this.form.category);
            })
            .finally(() => {
              if (newZip) {
                this.$modal.closeLoading();
              }
            })
        }
      });
    },
    // 取消按钮
    cancel() {
      this.show = false;
    },
    getFavicons() {
      if (!(this.form.url && this.form.url.startsWith('http'))) {
        return;
      }
      this.showFaviconLoading = true;
      this.$http.get('/api/v1/card/icon', {params: {url: this.form.url}})
        .then(res => {
          if (!(Array.isArray(res) && res.length > 0)) {
            return;
          }
          for (const url of res) {
            this.$refs.refCardIcon.uploadSuccess(url);
          }
        })
        .finally(() => {
          this.showFaviconLoading = false;
        });
    },
    
    // 检查URL参数并自动填充
    checkUrlParams() {
      const urlParams = new URLSearchParams(window.location.search);
      const url = urlParams.get('url');
      const title = urlParams.get('title');
      const favicon = urlParams.get('favicon');
      
      if (url) {
        // 如果有URL参数，调用API获取自动填充数据
        this.$http.get('/api/v1/card/auto-fill', {
          params: {
            url: url,
            title: title,
            favicon: favicon
          }
        }).then(res => {
          if (res) {
            this.form = {...this.form, ...res};
            // 如果有图标，初始化图标选择器
            if (res.icon) {
              this.$nextTick(() => {
                this.$refs.refCardIcon.init(res.icon);
              });
            }
          }
        }).catch(err => {
          console.error('获取自动填充数据失败:', err);
          // 如果API调用失败，至少填充URL和标题
          if (url) {
            this.form.url = url;
          }
          if (title) {
            this.form.title = title;
          }
        });
      }
    },
  },
}
