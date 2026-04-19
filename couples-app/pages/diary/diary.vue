<template>
  <div class="diary-container">
    <!-- 日记头部 -->
    <div class="diary-header">
      <h2 class="diary-title">我们的日记</h2>
      <button class="add-btn" @click="createDiary">+ 写日记</button>
    </div>
    
    <!-- 日记列表 -->
    <div class="diary-list">
      <div v-for="(diary, index) in diaries" :key="index" class="diary-item">
        <div class="diary-header-info">
          <h3 class="diary-item-title">{{ diary.title }}</h3>
          <div class="diary-item-meta">
            <span class="diary-author">{{ diary.author }}</span>
            <span class="diary-date">{{ diary.date }}</span>
            <span class="diary-weather">{{ diary.weather }}</span>
            <span class="diary-location">{{ diary.location }}</span>
          </div>
        </div>
        <div class="diary-content">{{ diary.content }}</div>
        <div class="diary-actions">
          <span class="diary-action" @click="likeDiary(index)">
            {{ diary.liked ? '❤️' : '🤍' }} {{ diary.likeCount }}
          </span>
          <span class="diary-action" @click="commentDiary(index)">
            💬 {{ diary.commentList.length }}
          </span>
        </div>
      </div>
    </div>
    
    <!-- 写日记弹窗 -->
    <div class="diary-modal" v-if="showCreate">
      <div class="diary-modal-content">
        <h3 class="modal-title">写日记</h3>
        <div class="form-group">
          <label class="form-label">标题</label>
          <input type="text" v-model="newDiary.title" class="input" placeholder="请输入标题">
        </div>
        <div class="form-group">
          <label class="form-label">内容</label>
          <textarea v-model="newDiary.content" class="textarea" placeholder="写下你的心情..."></textarea>
        </div>
        <div class="form-group">
          <label class="form-label">天气</label>
          <select v-model="newDiary.weather" class="select">
            <option value="晴天">晴天</option>
            <option value="多云">多云</option>
            <option value="雨天">雨天</option>
            <option value="雪天">雪天</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">地点</label>
          <input type="text" v-model="newDiary.location" class="input" placeholder="请输入地点">
        </div>
        <div class="modal-actions">
          <button class="btn cancel-btn" @click="showCreate = false">取消</button>
          <button class="btn save-btn" @click="saveDiary">保存</button>
        </div>
      </div>
    </div>
    
    <!-- 评论弹窗 -->
    <div class="comment-modal" v-if="showComment">
      <div class="comment-content">
        <h3 class="comment-title">评论</h3>
        <div class="comment-list">
          <div v-for="(comment, index) in currentDiary.commentList" :key="index" class="comment-item">
            <span class="comment-author">{{ comment.author }}:</span>
            <span class="comment-text">{{ comment.content }}</span>
          </div>
        </div>
        <div class="comment-input">
          <input type="text" v-model="newComment" placeholder="写下你的评论..." class="input">
          <button class="btn comment-btn" @click="submitComment">发送</button>
        </div>
        <button class="btn close-btn" @click="showComment = false">关闭</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      diaries: [],
      showCreate: false,
      showComment: false,
      currentDiary: null,
      newComment: '',
      newDiary: {
        title: '',
        content: '',
        weather: '晴天',
        location: ''
      },
      coupleId: null,
      userInfo: null
    }
  },
  onLoad() {
    this.userInfo = getApp().globalData.userInfo
    this.coupleId = getApp().globalData.coupleId
    this.loadDiaries()
  },
  methods: {
    // 加载日记
    async loadDiaries() {
      if (!this.coupleId) {
        this.$showToast({
          title: '请先绑定情侣关系',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '加载中...' })
        
        // 调用云函数获取日记
        const res = await uniCloud.callFunction({
          name: 'getDiaries'
        })
        
        if (res.result.code === 0 && res.result.data && Array.isArray(res.result.data)) {
          this.diaries = res.result.data
        }
        
        this.$hideLoading()
      } catch (error) {
        console.error('加载日记失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '加载失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 创建日记
    createDiary() {
      this.newDiary = {
        title: '',
        content: '',
        weather: '晴天',
        location: ''
      }
      this.showCreate = true
    },
    
    // 保存日记
    async saveDiary() {
      if (!this.newDiary.title || !this.newDiary.content) {
        this.$showToast({
          title: '请填写标题和内容',
          icon: 'none'
        })
        return
      }
      
      if (!this.coupleId) {
        this.$showToast({
          title: '请先绑定情侣关系',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '保存中...' })
        
        // 调用云函数保存日记
        const res = await uniCloud.callFunction({
          name: 'addDiary',
          data: this.newDiary
        })
        
        if (res.result.code === 0) {
          // 重新加载日记
          await this.loadDiaries()
          
          this.showCreate = false
          this.$hideLoading()
          this.$showToast({
            title: '保存成功',
            icon: 'success'
          })
        } else {
          throw new Error(res.result.message || '保存失败')
        }
      } catch (error) {
        console.error('保存日记失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: error.message || '保存失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 点赞日记
    async likeDiary(index) {
      const diary = this.diaries[index]
      try {
        // 调用云函数点赞日记
        const res = await uniCloud.callFunction({
          name: 'likeDiary',
          data: {
            diaryId: diary._id,
            liked: !diary.liked
          }
        })
        
        if (res.result.code === 0) {
          // 更新本地状态
          if (diary.liked) {
            diary.likeCount--
          } else {
            diary.likeCount++
          }
          diary.liked = !diary.liked
        } else {
          throw new Error(res.result.message || '操作失败')
        }
      } catch (error) {
        console.error('点赞失败:', error)
        this.$showToast({
          title: error.message || '操作失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 评论日记
    commentDiary(index) {
      this.currentDiary = this.diaries[index]
      this.showComment = true
      this.newComment = ''
    },
    
    // 提交评论
    async submitComment() {
      if (!this.newComment.trim()) return
      
      try {
        // 调用云函数提交评论
        const res = await uniCloud.callFunction({
          name: 'addDiaryComment',
          data: {
            diaryId: this.currentDiary._id,
            content: this.newComment
          }
        })
        
        if (res.result.code === 0) {
          // 更新本地状态
          this.currentDiary.commentList.push({
            author: this.userInfo.nickname,
            content: this.newComment
          })
          
          this.newComment = ''
          this.$showToast({
            title: '评论成功',
            icon: 'success'
          })
        } else {
          throw new Error(res.result.message || '评论失败')
        }
      } catch (error) {
        console.error('评论失败:', error)
        this.$showToast({
          title: error.message || '评论失败，请稍后重试',
          icon: 'none'
        })
      }
    }
  }
}
</script>

<style scoped>
.diary-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.diary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.diary-title {
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.add-btn {
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

.add-btn:hover {
  background-color: #ff5252;
}

.diary-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.diary-item {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
  transition: transform 0.3s;
}

.diary-item:hover {
  transform: translateY(-5px);
}

.diary-header-info {
  margin-bottom: 15px;
}

.diary-item-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 10px;
}

.diary-item-meta {
  display: flex;
  gap: 15px;
  font-size: 14px;
  color: #999;
}

.diary-content {
  font-size: 16px;
  color: #666;
  line-height: 1.6;
  margin-bottom: 15px;
}

.diary-actions {
  display: flex;
  gap: 15px;
  font-size: 14px;
  color: #666;
}

.diary-action {
  cursor: pointer;
  transition: color 0.3s;
}

.diary-action:hover {
  color: #ff6b6b;
}

.diary-modal,
.comment-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.diary-modal-content,
.comment-content {
  background-color: white;
  border-radius: 12px;
  padding: 20px;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.modal-title,
.comment-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  text-align: center;
}

.form-group {
  margin-bottom: 15px;
}

.form-label {
  display: block;
  font-size: 14px;
  color: #666;
  margin-bottom: 5px;
}

.input,
.select,
.textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s;
}

.input:focus,
.select:focus,
.textarea:focus {
  border-color: #ff6b6b;
}

.textarea {
  resize: vertical;
  min-height: 120px;
}

.modal-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.cancel-btn {
  flex: 1;
  padding: 10px;
  background-color: #f0f0f0;
  color: #333;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.cancel-btn:hover {
  background-color: #e0e0e0;
}

.save-btn {
  flex: 1;
  padding: 10px;
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

.save-btn:hover {
  background-color: #ff5252;
}

.comment-list {
  margin-bottom: 20px;
}

.comment-item {
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-author {
  font-weight: bold;
  color: #333;
  margin-right: 10px;
}

.comment-text {
  color: #666;
}

.comment-input {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.comment-btn {
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 0 16px;
  font-size: 14px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

.comment-btn:hover {
  background-color: #ff5252;
}

.close-btn {
  width: 100%;
  padding: 10px;
  background-color: #f0f0f0;
  color: #333;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.close-btn:hover {
  background-color: #e0e0e0;
}
</style>