<template>
  <div class="chat-container">
    <!-- 聊天消息区域 -->
    <div class="message-list" ref="messageList">
      <div v-for="(message, index) in messages" :key="message._id || index" :class="['message-item', message.isMe ? 'me' : 'other']">
        <div class="message-avatar">{{ message.avatar }}</div>
        <div class="message-content">
          <div class="message-text">{{ message.content }}</div>
          <div class="message-time">
            {{ message.time }}
            <span v-if="message.isMe && message.isRead" class="read-status">已读</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 输入区域 -->
    <div class="input-section">
      <button class="emoji-btn" @click="toggleEmoji">😊</button>
      <input type="text" v-model="inputMessage" class="chat-input" placeholder="输入消息...">
      <button class="send-btn" @click="sendMessage">发送</button>
    </div>
    
    <!-- 表情面板 -->
    <div class="emoji-panel" v-if="showEmoji">
      <div class="emoji-list">
        <span v-for="(emoji, index) in emojis" :key="index" @click="selectEmoji(emoji)">{{ emoji }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      messages: [],
      inputMessage: '',
      showEmoji: false,
      emojis: ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥', '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐', '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤠'],
      coupleId: null,
      userInfo: null,
      messageListener: null
    }
  },
  onLoad() {
    this.userInfo = getApp().globalData.userInfo
    this.coupleId = getApp().globalData.coupleId
    this.loadMessages()
    this.startMessageListener()
  },
  onUnload() {
    this.stopMessageListener()
  },
  methods: {
    // 加载消息
    async loadMessages() {
      if (!this.coupleId) {
        this.$showToast({
          title: '请先绑定情侣关系',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '加载中...' })
        
        // 调用云函数获取消息
        const res = await uniCloud.callFunction({
          name: 'getMessages',
          data: { coupleId: this.coupleId }
        })
        
        if (res.result.code === 0 && res.result.data && Array.isArray(res.result.data)) {
          this.messages = res.result.data.map(msg => ({
            ...msg,
            isMe: msg.senderId === this.userInfo._id,
            time: this.formatTime(msg.createdAt),
            avatar: msg.isMe ? '👨' : '👩'
          }))
        }
        
        this.$hideLoading()
        this.scrollToBottom()
      } catch (error) {
        console.error('加载消息失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '加载消息失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 发送消息
    async sendMessage() {
      if (!this.inputMessage.trim()) return
      if (!this.coupleId) {
        this.$showToast({
          title: '请先绑定情侣关系',
          icon: 'none'
        })
        return
      }
      
      const content = this.inputMessage.trim()
      const time = this.getCurrentTime()
      const tempId = Date.now().toString()
      
      // 先添加到本地，优化用户体验
      const newMessage = {
        _id: tempId,
        isMe: true,
        content,
        time,
        avatar: '👨',
        isRead: false,
        createdAt: new Date()
      }
      
      this.messages.push(newMessage)
      this.inputMessage = ''
      this.scrollToBottom()
      
      try {
        // 调用云函数发送消息
        const res = await uniCloud.callFunction({
          name: 'sendMessage',
          data: { 
            content, 
            coupleId: this.coupleId 
          }
        })
        
        if (res.result.code === 0) {
          // 更新消息ID
          const index = this.messages.findIndex(msg => msg._id === tempId)
          if (index !== -1) {
            this.messages[index]._id = res.result.data.messageId
          }
        }
      } catch (error) {
        console.error('发送消息失败:', error)
        // 发送失败，从本地移除
        const index = this.messages.findIndex(msg => msg._id === tempId)
        if (index !== -1) {
          this.messages.splice(index, 1)
        }
        this.$showToast({
          title: '发送失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 开始监听消息
    startMessageListener() {
      if (!this.coupleId) return
      
      // 使用uniCloud的实时数据库监听
      this.messageListener = uniCloud.database().collection('messages')
        .where({ coupleId: this.coupleId })
        .watch({
          onChange: (snapshot) => {
            if (snapshot.docs && snapshot.docs.length > 0) {
              snapshot.docs.forEach(doc => {
                const existingIndex = this.messages.findIndex(msg => msg._id === doc._id)
                if (existingIndex === -1) {
                  // 新消息
                  const newMessage = {
                    ...doc,
                    isMe: doc.senderId === this.userInfo._id,
                    time: this.formatTime(doc.createdAt),
                    avatar: doc.senderId === this.userInfo._id ? '👨' : '👩'
                  }
                  this.messages.push(newMessage)
                  this.scrollToBottom()
                  
                  // 如果是对方发送的消息，标记为已读
                  if (!newMessage.isMe) {
                    this.markAsRead(doc._id)
                  }
                } else {
                  // 更新消息状态
                  this.messages[existingIndex].isRead = doc.isRead
                }
              })
            }
          },
          onError: (error) => {
            console.error('消息监听失败:', error)
          }
        })
    },
    
    // 停止监听消息
    stopMessageListener() {
      if (this.messageListener) {
        this.messageListener.close()
        this.messageListener = null
      }
    },
    
    // 标记消息为已读
    async markAsRead(messageId) {
      try {
        await uniCloud.callFunction({
          name: 'markMessageAsRead',
          data: { messageId }
        })
      } catch (error) {
        console.error('标记消息已读失败:', error)
      }
    },
    
    // 格式化时间
    formatTime(time) {
      const date = new Date(time)
      const hours = date.getHours().toString().padStart(2, '0')
      const minutes = date.getMinutes().toString().padStart(2, '0')
      return `${hours}:${minutes}`
    },
    
    // 获取当前时间
    getCurrentTime() {
      return this.formatTime(new Date())
    },
    
    // 滚动到底部
    scrollToBottom() {
      setTimeout(() => {
        const messageList = this.$refs.messageList
        if (messageList) {
          messageList.scrollTop = messageList.scrollHeight
        }
      }, 100)
    },
    
    // 切换表情面板
    toggleEmoji() {
      this.showEmoji = !this.showEmoji
    },
    
    // 选择表情
    selectEmoji(emoji) {
      this.inputMessage += emoji
    }
  },
  mounted() {
    this.scrollToBottom()
  }
}
</script>

<style scoped>
.chat-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background-color: #f5f5f5;
}

.message-list {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.message-item {
  display: flex;
  align-items: flex-end;
  gap: 10px;
}

.message-item.me {
  flex-direction: row-reverse;
}

.message-avatar {
  font-size: 32px;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background-color: #f0f0f0;
}

.message-content {
  max-width: 70%;
}

.message-item.me .message-content {
  text-align: right;
}

.message-text {
  padding: 10px 15px;
  border-radius: 18px;
  font-size: 16px;
  line-height: 1.4;
}

.message-item.me .message-text {
  background-color: #ff6b6b;
  color: white;
  border-bottom-right-radius: 4px;
}

.message-item.other .message-text {
  background-color: white;
  color: #333;
  border-bottom-left-radius: 4px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.message-time {
  font-size: 12px;
  color: #999;
  margin-top: 5px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 5px;
}

.read-status {
  font-size: 11px;
  color: #ff6b6b;
}

.input-section {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 20px;
  background-color: white;
  border-top: 1px solid #eee;
}

.emoji-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  padding: 5px;
}

.chat-input {
  flex: 1;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 20px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s;
}

.chat-input:focus {
  border-color: #ff6b6b;
}

.send-btn {
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 20px;
  padding: 12px 20px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.send-btn:hover {
  background-color: #ff5252;
}

.emoji-panel {
  background-color: white;
  border-top: 1px solid #eee;
  padding: 15px;
  max-height: 200px;
  overflow-y: auto;
}

.emoji-list {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 10px;
}

.emoji-list span {
  font-size: 24px;
  text-align: center;
  cursor: pointer;
  padding: 5px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.emoji-list span:hover {
  background-color: #f0f0f0;
}
</style>