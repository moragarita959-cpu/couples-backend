<template>
  <div class="album-container">
    <!-- 相册头部 -->
    <div class="album-header">
      <h2 class="album-title">我们的相册</h2>
      <button class="add-btn" @click="uploadImage">+ 上传照片</button>
    </div>
    
    <!-- 照片网格 -->
    <div class="photo-grid">
      <div v-for="(photo, index) in photos" :key="index" class="photo-item">
        <img :src="photo.url" :alt="photo.description" class="photo-image">
        <div class="photo-info">
          <div class="photo-description">{{ photo.description }}</div>
          <div class="photo-actions">
            <span class="photo-action" @click="likePhoto(index)">
              {{ photo.liked ? '❤️' : '🤍' }} {{ photo.likeCount }}
            </span>
            <span class="photo-action" @click="commentPhoto(index)">
              💬 {{ photo.commentList.length }}
            </span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 评论弹窗 -->
    <div class="comment-modal" v-if="showComment">
      <div class="comment-content">
        <h3 class="comment-title">评论</h3>
        <div class="comment-list">
          <div v-for="(comment, index) in currentPhoto.commentList" :key="index" class="comment-item">
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
      photos: [],
      showComment: false,
      currentPhoto: null,
      newComment: '',
      coupleId: null,
      userInfo: null
    }
  },
  onLoad() {
    this.userInfo = getApp().globalData.userInfo
    this.coupleId = getApp().globalData.coupleId
    this.loadPhotos()
  },
  methods: {
    // 加载照片
    async loadPhotos() {
      if (!this.coupleId) {
        this.$showToast({
          title: '请先绑定情侣关系',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '加载中...' })
        
        // 调用云函数获取照片
        const res = await uniCloud.callFunction({
          name: 'getPhotos'
        })
        
        if (res.result.code === 0 && res.result.data && Array.isArray(res.result.data)) {
          this.photos = res.result.data
        }
        
        this.$hideLoading()
      } catch (error) {
        console.error('加载照片失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '加载失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 上传照片
    uploadImage() {
      if (!this.coupleId) {
        this.$showToast({
          title: '请先绑定情侣关系',
          icon: 'none'
        })
        return
      }
      
      uni.chooseImage({
        count: 1,
        success: async (res) => {
          try {
            this.$showLoading({ title: '上传中...' })
            
            // 调用云函数上传照片
            const uploadResult = await uniCloud.uploadFile({
              cloudPath: `photos/${Date.now()}.jpg`,
              filePath: res.tempFilePaths[0]
            })
            
            // 调用云函数保存照片信息
            const addResult = await uniCloud.callFunction({
              name: 'addPhoto',
              data: {
                url: uploadResult.fileID,
                description: '新照片'
              }
            })
            
            if (addResult.result.code === 0) {
              // 重新加载照片
              await this.loadPhotos()
              
              this.$hideLoading()
              this.$showToast({
                title: '上传成功',
                icon: 'success'
              })
            } else {
              throw new Error(addResult.result.message || '上传失败')
            }
          } catch (error) {
            console.error('上传照片失败:', error)
            this.$hideLoading()
            this.$showToast({
              title: error.message || '上传失败，请稍后重试',
              icon: 'none'
            })
          }
        }
      })
    },
    
    // 点赞照片
    async likePhoto(index) {
      const photo = this.photos[index]
      try {
        // 调用云函数点赞照片
        const res = await uniCloud.callFunction({
          name: 'likePhoto',
          data: {
            photoId: photo._id,
            liked: !photo.liked
          }
        })
        
        if (res.result.code === 0) {
          // 更新本地状态
          if (photo.liked) {
            photo.likeCount--
          } else {
            photo.likeCount++
          }
          photo.liked = !photo.liked
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
    
    // 评论照片
    commentPhoto(index) {
      this.currentPhoto = this.photos[index]
      this.showComment = true
      this.newComment = ''
    },
    
    // 提交评论
    async submitComment() {
      if (!this.newComment.trim()) return
      
      try {
        // 调用云函数提交评论
        const res = await uniCloud.callFunction({
          name: 'addComment',
          data: {
            photoId: this.currentPhoto._id,
            content: this.newComment
          }
        })
        
        if (res.result.code === 0) {
          // 更新本地状态
          this.currentPhoto.commentList.push({
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
.album-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.album-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.album-title {
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

.photo-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
}

.photo-item {
  background-color: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s;
}

.photo-item:hover {
  transform: translateY(-5px);
}

.photo-image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.photo-info {
  padding: 15px;
}

.photo-description {
  font-size: 14px;
  color: #333;
  margin-bottom: 10px;
}

.photo-actions {
  display: flex;
  gap: 15px;
  font-size: 14px;
  color: #666;
}

.photo-action {
  cursor: pointer;
  transition: color 0.3s;
}

.photo-action:hover {
  color: #ff6b6b;
}

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

.comment-content {
  background-color: white;
  border-radius: 12px;
  padding: 20px;
  width: 90%;
  max-width: 400px;
  max-height: 80vh;
  overflow-y: auto;
}

.comment-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
  text-align: center;
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

.input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 20px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.3s;
}

.input:focus {
  border-color: #ff6b6b;
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