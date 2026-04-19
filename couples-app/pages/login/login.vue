<template>
  <div class="login-container">
    <div class="login-card">
      <h1 class="app-title">好意</h1>
      <p class="app-desc">专属你们的私密空间</p>
      
      <div class="form-group">
        <input type="text" v-model="phone" class="input" placeholder="请输入手机号" maxlength="11" @input="handlePhoneInput">
      </div>
      
      <div class="form-group">
        <input type="text" v-model="code" class="input" placeholder="请输入验证码" @input="handleCodeInput">
        <button class="code-btn" @click="sendCode" :disabled="countdown > 0">
          {{ countdown > 0 ? `${countdown}s后重新发送` : '发送验证码' }}
        </button>
      </div>
      
      <div class="agreement">
        <input type="checkbox" :checked="agreed" @change="agreed = !agreed" id="agreement">
        <label for="agreement">登录即表示同意<a href="#" @click.prevent="showUserAgreement">用户协议</a>和<a href="#" @click.prevent="showPrivacyPolicy">隐私政策</a></label>
      </div>
      
      <button class="btn login-btn" @click="login" :disabled="!agreed">登录/注册</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      phone: '',
      code: '',
      countdown: 0,
      timer: null,
      agreed: false
    }
  },
  methods: {
    // 处理手机号输入
    handlePhoneInput(event) {
      this.phone = event.target.value
    },
    
    // 处理验证码输入
    handleCodeInput(event) {
      this.code = event.target.value
    },
    
    // 发送验证码
    async sendCode() {
      if (!this.phone || this.phone.length !== 11) {
        this.$showToast({
          title: '请输入正确的手机号',
          icon: 'none'
        })
        return
      }
      
      try {
        // 调用云函数发送验证码
        await this.$cloud.callFunction('sendCode', { phone: this.phone })
        
        this.$showToast({
          title: '验证码已发送',
          icon: 'success'
        })
        
        // 开始倒计时
        this.countdown = 60
        this.timer = setInterval(() => {
          this.countdown--
          if (this.countdown <= 0) {
            clearInterval(this.timer)
          }
        }, 1000)
      } catch (error) {
        console.error('发送验证码失败:', error)
        this.$showToast({
          title: '发送验证码失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 登录
    async login() {
      if (!this.phone || this.phone.length !== 11) {
        this.$showToast({
          title: '请输入正确的手机号',
          icon: 'none'
        })
        return
      }
      
      if (!this.code) {
        this.$showToast({
          title: '请输入验证码',
          icon: 'none'
        })
        return
      }
      
      if (!this.agreed) {
        this.$showToast({
          title: '请阅读并同意用户协议和隐私政策',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '登录中...' })
        
        // 调用云函数进行登录
        const userInfo = await this.$cloud.callFunction('login', {
          phone: this.phone,
          code: this.code
        })
        
        // 存储用户信息
        uni.setStorageSync('userInfo', userInfo)
        uni.setStorageSync('token', userInfo.token)
        
        this.$hideLoading()
        this.$showToast({
          title: '登录成功',
          icon: 'success'
        })
        
        // 跳转到首页
        uni.switchTab({
          url: '/pages/index/index'
        })
      } catch (error) {
        console.error('登录失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: error.message || '登录失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 显示用户协议
    showUserAgreement() {
      uni.showModal({
        title: '用户协议',
        content: '用户协议内容...',
        showCancel: false
      })
    },
    
    // 显示隐私政策
    showPrivacyPolicy() {
      uni.showModal({
        title: '隐私政策',
        content: '隐私政策内容...',
        showCancel: false
      })
    }
  },
  beforeUnmount() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f5f5;
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  padding: 40px 30px;
  text-align: center;
}

.app-title {
  font-size: 28px;
  font-weight: bold;
  color: #ff6b6b;
  margin-bottom: 10px;
}

.app-desc {
  color: #666;
  margin-bottom: 40px;
}

.form-group {
  position: relative;
  margin-bottom: 20px;
}

.input {
  width: 100%;
  padding: 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s;
}

.input:focus {
  border-color: #ff6b6b;
}

.code-btn {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.code-btn:hover {
  background-color: #ff5252;
}

.code-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.agreement {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
  font-size: 14px;
  color: #666;
  text-align: left;
}

.agreement input[type="checkbox"] {
  margin-right: 10px;
  transform: scale(1.2);
}

.agreement a {
  color: #ff6b6b;
  text-decoration: none;
}

.login-btn {
  width: 100%;
  padding: 15px;
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

.login-btn:hover {
  background-color: #ff5252;
}

.login-btn:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}
</style>