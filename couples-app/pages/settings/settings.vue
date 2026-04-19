<template>
  <div class="settings-container">
    <div class="settings-card">
      <h2 class="settings-title">设置</h2>
      
      <div class="settings-section">
        <h3 class="section-title">账户设置</h3>
        <div class="setting-item" @click="editProfile">
          <span class="setting-label">个人资料</span>
          <span class="setting-arrow">→</span>
        </div>
        <div class="setting-item" @click="changePassword">
          <span class="setting-label">修改密码</span>
          <span class="setting-arrow">→</span>
        </div>
      </div>
      
      <div class="settings-section">
        <h3 class="section-title">通知设置</h3>
        <div class="setting-item">
          <span class="setting-label">新消息通知</span>
          <label class="switch">
            <input type="checkbox" v-model="notifications.message">
            <span class="slider"></span>
          </label>
        </div>
        <div class="setting-item">
          <span class="setting-label">戳一下通知</span>
          <label class="switch">
            <input type="checkbox" v-model="notifications.poke">
            <span class="slider"></span>
          </label>
        </div>
        <div class="setting-item">
          <span class="setting-label">账单通知</span>
          <label class="switch">
            <input type="checkbox" v-model="notifications.bill">
            <span class="slider"></span>
          </label>
        </div>
      </div>
      
      <div class="settings-section">
        <h3 class="section-title">情侣关系</h3>
        <div class="setting-item" @click="editAnniversary">
          <span class="setting-label">纪念日设置</span>
          <span class="setting-arrow">→</span>
        </div>
        <div class="setting-item" @click="editMeetDate">
          <span class="setting-label">见面日期设置</span>
          <span class="setting-arrow">→</span>
        </div>
        <div class="setting-item danger" @click="unbind">
          <span class="setting-label">解除绑定</span>
          <span class="setting-arrow">→</span>
        </div>
      </div>
      
      <div class="settings-section">
        <h3 class="section-title">其他</h3>
        <div class="setting-item" @click="exportData">
          <span class="setting-label">导出数据</span>
          <span class="setting-arrow">→</span>
        </div>
        <div class="setting-item" @click="about">
          <span class="setting-label">关于我们</span>
          <span class="setting-arrow">→</span>
        </div>
        <div class="setting-item" @click="logout">
          <span class="setting-label">退出登录</span>
          <span class="setting-arrow">→</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      notifications: {
        message: true,
        poke: true,
        bill: true
      }
    }
  },
  methods: {
    // 编辑个人资料
    editProfile() {
      uni.navigateTo({
        url: '/pages/settings/edit-profile'
      })
    },
    
    // 修改密码
    changePassword() {
      uni.navigateTo({
        url: '/pages/settings/change-password'
      })
    },
    
    // 编辑纪念日
    async editAnniversary() {
      uni.showDatePicker({
        success: async (res) => {
          try {
            // 调用云函数更新纪念日
            await this.$cloud.callFunction('updateAnniversary', {
              date: res.value
            })
            this.$showToast({
              title: '纪念日已更新',
              icon: 'success'
            })
          } catch (error) {
            console.error('更新纪念日失败:', error)
            this.$showToast({
              title: '更新失败，请稍后重试',
              icon: 'none'
            })
          }
        }
      })
    },
    
    // 编辑见面日期
    async editMeetDate() {
      uni.showDatePicker({
        success: async (res) => {
          try {
            // 调用云函数更新见面日期
            await this.$cloud.callFunction('updateMeetDate', {
              date: res.value
            })
            this.$showToast({
              title: '见面日期已更新',
              icon: 'success'
            })
          } catch (error) {
            console.error('更新见面日期失败:', error)
            this.$showToast({
              title: '更新失败，请稍后重试',
              icon: 'none'
            })
          }
        }
      })
    },
    
    // 解除绑定
    unbind() {
      uni.showModal({
        title: '解除绑定',
        content: '确定要解除情侣绑定吗？解除后将无法恢复所有数据。',
        confirmText: '确定',
        cancelText: '取消',
        success: async (res) => {
          if (res.confirm) {
            try {
              this.$showLoading({ title: '处理中...' })
              
              // 调用云函数解除绑定
              await this.$cloud.callFunction('unbind')
              
              // 清除本地存储
              uni.removeStorageSync('userInfo')
              uni.removeStorageSync('token')
              
              this.$hideLoading()
              this.$showToast({
                title: '绑定已解除',
                icon: 'success'
              })
              
              // 跳转到登录页面
              uni.redirectTo({
                url: '/pages/login/login'
              })
            } catch (error) {
              console.error('解除绑定失败:', error)
              this.$hideLoading()
              this.$showToast({
                title: '解除绑定失败，请稍后重试',
                icon: 'none'
              })
            }
          }
        }
      })
    },
    
    // 导出数据
    async exportData() {
      try {
        this.$showLoading({ title: '导出中...' })
        
        // 调用云函数导出数据
        const result = await this.$cloud.callFunction('exportData')
        
        // 处理导出结果
        if (result.downloadUrl) {
          // 下载数据文件
          uni.downloadFile({
            url: result.downloadUrl,
            success: (res) => {
              this.$hideLoading()
              this.$showToast({
                title: '数据导出成功',
                icon: 'success'
              })
            },
            fail: (error) => {
              this.$hideLoading()
              this.$showToast({
                title: '下载失败，请稍后重试',
                icon: 'none'
              })
            }
          })
        } else {
          this.$hideLoading()
          this.$showToast({
            title: '数据导出成功',
            icon: 'success'
          })
        }
      } catch (error) {
        console.error('导出数据失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '导出失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 关于我们
    about() {
      uni.showModal({
        title: '关于我们',
        content: '情侣APP v1.0.0\n专属你们的私密空间',
        showCancel: false
      })
    },
    
    // 退出登录
    logout() {
      uni.showModal({
        title: '退出登录',
        content: '确定要退出登录吗？',
        confirmText: '确定',
        cancelText: '取消',
        success: async (res) => {
          if (res.confirm) {
            try {
              this.$showLoading({ title: '处理中...' })
              
              // 清除本地存储
              uni.removeStorageSync('userInfo')
              uni.removeStorageSync('token')
              
              // 调用云函数退出登录（如果需要）
              await this.$cloud.callFunction('logout')
              
              this.$hideLoading()
              uni.redirectTo({
                url: '/pages/login/login'
              })
            } catch (error) {
              console.error('退出登录失败:', error)
              this.$hideLoading()
              // 即使失败也要跳转到登录页面
              uni.redirectTo({
                url: '/pages/login/login'
              })
            }
          }
        }
      })
    }
  }
}
</script>

<style scoped>
.settings-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.settings-card {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.settings-title {
  font-size: 20px;
  font-weight: bold;
  color: #333;
  padding: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.settings-section {
  border-bottom: 1px solid #f0f0f0;
}

.settings-section:last-child {
  border-bottom: none;
}

.section-title {
  font-size: 14px;
  font-weight: bold;
  color: #999;
  padding: 15px 20px 10px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.setting-item:hover {
  background-color: #f9f9f9;
}

.setting-item.danger {
  color: #ff6b6b;
}

.setting-label {
  font-size: 16px;
  color: #333;
}

.setting-item.danger .setting-label {
  color: #ff6b6b;
}

.setting-arrow {
  font-size: 14px;
  color: #999;
}

.switch {
  position: relative;
  display: inline-block;
  width: 40px;
  height: 20px;
}

.switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  transition: .4s;
  border-radius: 20px;
}

.slider:before {
  position: absolute;
  content: "";
  height: 16px;
  width: 16px;
  left: 2px;
  bottom: 2px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
}

input:checked + .slider {
  background-color: #ff6b6b;
}

input:checked + .slider:before {
  transform: translateX(20px);
}
</style>