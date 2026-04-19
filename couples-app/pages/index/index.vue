<template>
  <div class="index-container">
    <!-- 顶部欢迎区域 -->
    <div class="welcome-section">
      <h1 class="welcome-title">亲爱的，你好</h1>
      <p class="welcome-subtitle">今天也是相爱的一天</p>
    </div>
    
    <!-- 统计数据区域 -->
    <div class="statistics-section">
      <div class="statistics-card">
        <h2 class="section-title">我们的故事</h2>
        <div class="statistics-grid">
          <div class="statistics-item">
            <div class="statistics-value">{{ statistics.consecutiveChatDays }}</div>
            <div class="statistics-label">连续聊天</div>
          </div>
          <div class="statistics-item">
            <div class="statistics-value">{{ statistics.totalMessages }}</div>
            <div class="statistics-label">总消息</div>
          </div>
          <div class="statistics-item">
            <div class="statistics-value">{{ statistics.todayMessages }}</div>
            <div class="statistics-label">今日消息</div>
          </div>
          <div class="statistics-item">
            <div class="statistics-value">{{ statistics.totalPhotos }}</div>
            <div class="statistics-label">总照片</div>
          </div>
          <div class="statistics-item">
            <div class="statistics-value">{{ statistics.totalDiaries }}</div>
            <div class="statistics-label">总日记</div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 倒计时区域 -->
    <div class="countdown-section">
      <div class="countdown-card">
        <h2 class="section-title">重要倒计时</h2>
        
        <div class="countdown-item">
          <div class="countdown-label">恋爱天数</div>
          <div class="countdown-value">{{ loveDays }}</div>
        </div>
        
        <div class="countdown-item">
          <div class="countdown-label">纪念日</div>
          <div class="countdown-value">{{ anniversaryDays }}天</div>
          <button class="edit-btn" @click="editAnniversary">编辑</button>
        </div>
        
        <div class="countdown-item">
          <div class="countdown-label">下次见面</div>
          <div class="countdown-value">{{ meetDays }}天</div>
          <button class="edit-btn" @click="editMeetDate">编辑</button>
        </div>
        
        <div class="countdown-item">
          <div class="countdown-label">生日</div>
          <div class="countdown-value">{{ birthdayDays }}天</div>
        </div>
      </div>
    </div>
    
    <!-- 距离区域 -->
    <div class="distance-section">
      <div class="distance-card">
        <h2 class="section-title">我们的距离</h2>
        <div class="distance-value">{{ distance }}</div>
        <div class="distance-status">
          <label class="switch">
            <input type="checkbox" v-model="distanceEnabled">
            <span class="slider"></span>
          </label>
          <span>开启距离功能</span>
        </div>
      </div>
    </div>
    
    <!-- 戳一下区域 -->
    <div class="poke-section">
      <div class="poke-card">
        <h2 class="section-title">互动</h2>
        <button class="poke-btn" @click="poke">
          <span class="poke-icon">👆</span>
          <span class="poke-text">戳一下</span>
        </button>
        <p class="poke-hint">给TA一个小惊喜</p>
      </div>
    </div>
    
    <!-- 快捷入口 -->
    <div class="quick-access">
      <h2 class="section-title">快捷入口</h2>
      <div class="quick-grid">
        <div class="quick-item" @click="navigateTo('/pages/chat/chat')">
          <div class="quick-icon">💬</div>
          <div class="quick-text">聊天</div>
        </div>
        <div class="quick-item" @click="navigateTo('/pages/bill/bill')">
          <div class="quick-icon">💰</div>
          <div class="quick-text">记账</div>
        </div>
        <div class="quick-item" @click="navigateTo('/pages/album/album')">
          <div class="quick-icon">📷</div>
          <div class="quick-text">相册</div>
        </div>
        <div class="quick-item" @click="navigateTo('/pages/diary/diary')">
          <div class="quick-icon">📝</div>
          <div class="quick-text">日记</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      loveDays: 0,
      anniversaryDays: 0,
      meetDays: 0,
      birthdayDays: 0,
      distance: '0 km',
      distanceEnabled: true,
      statistics: {
        consecutiveChatDays: 0,
        totalMessages: 0,
        todayMessages: 0,
        totalPhotos: 0,
        totalDiaries: 0
      }
    }
  },
  onLoad() {
    this.loadData()
  },
  methods: {
    // 加载数据
    async loadData() {
      try {
        this.$showLoading({ title: '加载中...' })
        
        // 并行加载数据
        const [coupleData, statisticsData] = await Promise.all([
          this.getCoupleData(),
          this.getStatistics()
        ])
        
        // 更新情侣数据
        if (coupleData) {
          this.loveDays = coupleData.loveDays || 0
          this.anniversaryDays = coupleData.anniversaryDays || 0
          this.meetDays = coupleData.meetDays || 0
          this.birthdayDays = coupleData.birthdayDays || 0
          this.distance = coupleData.distance || '0 km'
          this.distanceEnabled = coupleData.distanceEnabled !== false
        }
        
        // 更新统计数据
        if (statisticsData) {
          this.statistics = statisticsData
        }
        
        this.$hideLoading()
      } catch (error) {
        console.error('加载数据失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '加载失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 获取情侣数据
    async getCoupleData() {
      try {
        const res = await uniCloud.callFunction({
          name: 'getCoupleData'
        })
        return res.result.code === 0 ? res.result.data : null
      } catch (error) {
        console.error('获取情侣数据失败:', error)
        return null
      }
    },
    
    // 获取统计数据
    async getStatistics() {
      try {
        const res = await uniCloud.callFunction({
          name: 'getStatistics'
        })
        return res.result.code === 0 ? res.result.data : null
      } catch (error) {
        console.error('获取统计数据失败:', error)
        return null
      }
    },
    
    // 编辑纪念日
    async editAnniversary() {
      uni.showDatePicker({
        success: async (res) => {
          try {
            // 调用云函数更新纪念日
            const updateRes = await uniCloud.callFunction({
              name: 'updateAnniversary',
              data: { date: res.value }
            })
            
            if (updateRes.result.code === 0) {
              // 重新加载数据
              await this.loadData()
              
              this.$showToast({
                title: '纪念日已更新',
                icon: 'success'
              })
            } else {
              throw new Error(updateRes.result.message || '更新失败')
            }
          } catch (error) {
            console.error('更新纪念日失败:', error)
            this.$showToast({
              title: error.message || '更新失败，请稍后重试',
              icon: 'none'
            })
          }
        }
      })
    },
    
    // 编辑下次见面日期
    async editMeetDate() {
      uni.showDatePicker({
        success: async (res) => {
          try {
            // 调用云函数更新见面日期
            const updateRes = await uniCloud.callFunction({
              name: 'updateMeetDate',
              data: { date: res.value }
            })
            
            if (updateRes.result.code === 0) {
              // 重新加载数据
              await this.loadData()
              
              this.$showToast({
                title: '见面日期已更新',
                icon: 'success'
              })
            } else {
              throw new Error(updateRes.result.message || '更新失败')
            }
          } catch (error) {
            console.error('更新见面日期失败:', error)
            this.$showToast({
              title: error.message || '更新失败，请稍后重试',
              icon: 'none'
            })
          }
        }
      })
    },
    
    // 戳一下
    async poke() {
      try {
        // 调用云函数发送戳一下通知
        const res = await uniCloud.callFunction({
          name: 'poke'
        })
        
        if (res.result.code === 0) {
          this.$showToast({
            title: '已戳TA一下',
            icon: 'success'
          })
        } else {
          throw new Error(res.result.message || '发送失败')
        }
      } catch (error) {
        console.error('发送戳一下失败:', error)
        this.$showToast({
          title: error.message || '发送失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 导航到其他页面
    navigateTo(url) {
      uni.navigateTo({
        url
      })
    }
  }
}
</script>

<style scoped>
.index-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.welcome-section {
  text-align: center;
  margin-bottom: 30px;
}

.welcome-title {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
}

.welcome-subtitle {
  color: #666;
  font-size: 16px;
}

.section-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
}

.statistics-section,
.countdown-section,
.distance-section,
.poke-section,
.quick-access {
  margin-bottom: 30px;
}

.statistics-card {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
}

.statistics-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
}

.statistics-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 15px;
  background-color: #f9f9f9;
  border-radius: 8px;
  transition: transform 0.3s;
}

.statistics-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.statistics-value {
  font-size: 24px;
  font-weight: bold;
  color: #ff6b6b;
  margin-bottom: 5px;
}

.statistics-label {
  font-size: 14px;
  color: #666;
  text-align: center;
}

.countdown-card,
.distance-card,
.poke-card {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
}

.countdown-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.countdown-item:last-child {
  border-bottom: none;
}

.countdown-label {
  font-size: 16px;
  color: #666;
}

.countdown-value {
  font-size: 18px;
  font-weight: bold;
  color: #ff6b6b;
}

.edit-btn {
  background-color: #f0f0f0;
  border: none;
  border-radius: 4px;
  padding: 5px 10px;
  font-size: 14px;
  color: #666;
  cursor: pointer;
}

.distance-value {
  font-size: 36px;
  font-weight: bold;
  color: #ff6b6b;
  text-align: center;
  margin: 20px 0;
}

.distance-status {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 14px;
  color: #666;
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

.poke-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 50%;
  width: 120px;
  height: 120px;
  margin: 20px auto;
  cursor: pointer;
  transition: transform 0.3s;
}

.poke-btn:hover {
  transform: scale(1.1);
}

.poke-icon {
  font-size: 36px;
  margin-bottom: 10px;
}

.poke-text {
  font-size: 16px;
  font-weight: bold;
}

.poke-hint {
  text-align: center;
  color: #666;
  font-size: 14px;
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
}

.quick-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  transition: transform 0.3s;
}

.quick-item:hover {
  transform: translateY(-5px);
}

.quick-icon {
  font-size: 32px;
  margin-bottom: 10px;
}

.quick-text {
  font-size: 14px;
  color: #666;
}
</style>