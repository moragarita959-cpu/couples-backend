<template>
  <div class="bind-container">
    <div class="bind-card">
      <h1 class="bind-title">情侣绑定</h1>
      <p class="bind-desc">输入对方的手机号，发送绑定请求</p>
      
      <div class="form-group">
        <input type="tel" v-model="phone" class="input" placeholder="请输入对方手机号" maxlength="11">
      </div>
      
      <button class="btn bind-btn" @click="sendBindRequest">发送绑定请求</button>
      
      <div class="bind-tips">
        <h3>绑定流程</h3>
        <ol>
          <li>输入对方手机号</li>
          <li>发送绑定请求</li>
          <li>对方收到通知并确认</li>
          <li>绑定成功，开始使用</li>
        </ol>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      phone: ''
    }
  },
  methods: {
    // 发送绑定请求
    async sendBindRequest() {
      if (!this.phone || this.phone.length !== 11) {
        this.$showToast({
          title: '请输入正确的手机号',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '发送中...' })
        
        // 调用云函数发送绑定请求
        await this.$cloud.callFunction('sendBindRequest', { phone: this.phone })
        
        this.$hideLoading()
        this.$showToast({
          title: '绑定请求已发送',
          icon: 'success'
        })
        
        // 跳转到首页
        uni.switchTab({
          url: '/pages/index/index'
        })
      } catch (error) {
        console.error('发送绑定请求失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: error.message || '发送绑定请求失败，请稍后重试',
          icon: 'none'
        })
      }
    }
  }
}
</script>

<style scoped>
.bind-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f5f5;
  padding: 20px;
}

.bind-card {
  width: 100%;
  max-width: 400px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  padding: 40px 30px;
}

.bind-title {
  font-size: 24px;
  font-weight: bold;
  color: #ff6b6b;
  text-align: center;
  margin-bottom: 10px;
}

.bind-desc {
  color: #666;
  text-align: center;
  margin-bottom: 40px;
}

.form-group {
  margin-bottom: 30px;
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

.bind-btn {
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
  margin-bottom: 30px;
}

.bind-btn:hover {
  background-color: #ff5252;
}

.bind-tips {
  background-color: #f9f9f9;
  border-radius: 8px;
  padding: 20px;
}

.bind-tips h3 {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
}

.bind-tips ol {
  list-style: decimal;
  padding-left: 20px;
  color: #666;
  line-height: 1.6;
}

.bind-tips li {
  margin-bottom: 8px;
}
</style>