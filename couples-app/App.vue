<script>
export default {
  globalData: {
    userInfo: null,
    coupleId: null,
    bindStatus: {
      isBound: false,
      status: 0
    }
  },
  
  onLaunch() {
    // 初始化uniCloud
    this.initUniCloud()
    
    // 检查登录状态
    this.checkLoginStatus()
    
    // 监听绑定状态变化
    this.listenBindStatus()
  },
  
  methods: {
    // 初始化uniCloud
    initUniCloud() {
      if (typeof uniCloud !== 'undefined') {
        uniCloud.init({
          provider: 'tencent',
          spaceId: 'your-space-id',
          clientSecret: 'your-client-secret'
        })
      }
    },
    
    // 检查登录状态
    checkLoginStatus() {
      const userInfo = uni.getStorageSync('userInfo')
      if (userInfo) {
        this.globalData.userInfo = userInfo
      }
    },
    
    // 监听绑定状态变化
    listenBindStatus() {
      setInterval(async () => {
        if (this.globalData.userInfo) {
          try {
            const res = await uniCloud.callFunction({
              name: 'getBindStatus'
            })
            if (res.result.code === 0) {
              this.globalData.bindStatus = res.result.data.bindStatus
              if (res.result.data.bindStatus.coupleId) {
                this.globalData.coupleId = res.result.data.bindStatus.coupleId
              }
            }
          } catch (error) {
            console.error('监听绑定状态失败:', error)
          }
        }
      }, 5000) // 每5秒检查一次
    },
    
    // 显示Toast
    showToast(options) {
      uni.showToast({
        title: options.title || '操作成功',
        icon: options.icon || 'success',
        duration: options.duration || 2000
      })
    },
    
    // 显示Loading
    showLoading(options) {
      uni.showLoading({
        title: options.title || '加载中...',
        mask: true
      })
    },
    
    // 隐藏Loading
    hideLoading() {
      uni.hideLoading()
    }
  }
}
</script>

<style>
/* 全局样式 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'PingFang SC', 'Helvetica Neue', Arial, sans-serif;
  background-color: #f5f5f5;
  color: #333;
}

/* 通用按钮样式 */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-primary {
  background-color: #ff6b6b;
  color: white;
}

.btn-primary:hover {
  background-color: #ff5252;
}

/* 通用输入框样式 */
.input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s ease;
}

.input:focus {
  border-color: #ff6b6b;
}

/* 通用卡片样式 */
.card {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 20px;
}

/* 通用标题样式 */
h1, h2, h3, h4, h5, h6 {
  color: #333;
  margin-bottom: 10px;
}

/* 通用文本样式 */
p {
  color: #666;
  line-height: 1.5;
  margin-bottom: 10px;
}

/* 通用列表样式 */
ul, ol {
  padding-left: 20px;
  margin-bottom: 10px;
}

li {
  margin-bottom: 5px;
  color: #666;
}

/* 通用链接样式 */
a {
  color: #ff6b6b;
  text-decoration: none;
  transition: color 0.3s ease;
}

a:hover {
  color: #ff5252;
}

/* 通用错误提示样式 */
.error {
  color: #ff4757;
  font-size: 14px;
  margin-top: 5px;
}

/* 通用成功提示样式 */
.success {
  color: #2ed573;
  font-size: 14px;
  margin-top: 5px;
}

/* 通用加载样式 */
.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

/* 通用空状态样式 */
.empty {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 40px;
  color: #999;
  text-align: center;
}

/* 通用分割线样式 */
.divider {
  height: 1px;
  background-color: #eee;
  margin: 20px 0;
}
</style>