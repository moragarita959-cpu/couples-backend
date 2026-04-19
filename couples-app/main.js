import Vue from 'vue'
import App from './App.vue'

// 引入云开发
let cloud = {}
try {
  cloud = require('@/utils/cloud.js')
  console.log('云开发工具加载成功')
} catch (error) {
  console.error('云开发工具加载失败:', error)
  // 提供默认空对象，避免应用崩溃
  cloud.init = () => Promise.resolve(false)
  cloud.getDatabase = () => null
  cloud.getStorage = () => null
  cloud.callFunction = () => Promise.reject(new Error('云开发未初始化'))
  cloud.db = {
    query: () => Promise.reject(new Error('数据库未初始化')),
    add: () => Promise.reject(new Error('数据库未初始化')),
    update: () => Promise.reject(new Error('数据库未初始化')),
    remove: () => Promise.reject(new Error('数据库未初始化'))
  }
  cloud.storage = {
    uploadFile: () => Promise.reject(new Error('存储未初始化')),
    downloadFile: () => Promise.reject(new Error('存储未初始化')),
    deleteFile: () => Promise.reject(new Error('存储未初始化'))
  }
}

// 全局错误处理
Vue.config.errorHandler = (err, vm, info) => {
  console.error('Vue全局错误:', err)
  console.error('错误信息:', info)
}

// 全局未捕获异常处理
window.addEventListener('error', (event) => {
  console.error('全局未捕获异常:', event.error)
})

// 全局未处理的Promise拒绝处理
window.addEventListener('unhandledrejection', (event) => {
  console.error('未处理的Promise拒绝:', event.reason)
})

Vue.config.productionTip = false

// 挂载云开发到Vue实例
Vue.prototype.$cloud = cloud

// 挂载全局方法
Vue.prototype.$showToast = (options) => {
  uni.showToast({
    duration: 2000,
    ...options
  })
}

Vue.prototype.$showLoading = (options) => {
  uni.showLoading({
    mask: true,
    ...options
  })
}

Vue.prototype.$hideLoading = () => {
  uni.hideLoading()
}

new Vue({
  render: h => h(App)
}).$mount('#app')