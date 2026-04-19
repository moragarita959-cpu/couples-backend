<template>
  <div class="bill-container">
    <!-- 记账表单 -->
    <div class="bill-form">
      <h2 class="form-title">记一笔</h2>
      
      <div class="form-group">
        <label class="form-label">金额</label>
        <input type="number" v-model="bill.amount" class="input" placeholder="请输入金额">
      </div>
      
      <div class="form-group">
        <label class="form-label">类型</label>
        <div class="type-selector">
          <button class="type-btn" :class="{ active: bill.type === 2 }" @click="bill.type = 2">支出</button>
          <button class="type-btn" :class="{ active: bill.type === 1 }" @click="bill.type = 1">收入</button>
        </div>
      </div>
      
      <div class="form-group">
        <label class="form-label">分类</label>
        <select v-model="bill.category" class="select">
          <option value="餐饮">餐饮</option>
          <option value="交通">交通</option>
          <option value="购物">购物</option>
          <option value="娱乐">娱乐</option>
          <option value="其他">其他</option>
        </select>
      </div>
      
      <div class="form-group">
        <label class="form-label">日期</label>
        <input type="date" v-model="bill.date" class="input">
      </div>
      
      <div class="form-group">
        <label class="form-label">描述</label>
        <textarea v-model="bill.description" class="textarea" placeholder="请输入描述"></textarea>
      </div>
      
      <button class="btn submit-btn" @click="addBill">保存</button>
    </div>
    
    <!-- 账单列表 -->
    <div class="bill-list">
      <h2 class="list-title">最近账单</h2>
      
      <div v-for="(item, index) in bills" :key="index" class="bill-item">
        <div class="bill-info">
          <div class="bill-category">{{ item.category }}</div>
          <div class="bill-description">{{ item.description }}</div>
          <div class="bill-date">{{ item.date }}</div>
        </div>
        <div class="bill-amount" :class="item.type === 2 ? 'expense' : 'income'">
          {{ item.type === 2 ? '-' : '+' }}{{ item.amount }}元
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      bill: {
        amount: '',
        type: 2, // 默认支出
        category: '餐饮',
        date: new Date().toISOString().split('T')[0],
        description: ''
      },
      bills: []
    }
  },
  onLoad() {
    this.loadBills()
  },
  methods: {
    // 加载账单
    async loadBills() {
      try {
        this.$showLoading({ title: '加载中...' })
        
        // 调用云函数获取账单
        const bills = await this.$cloud.callFunction('getBills')
        
        if (bills && Array.isArray(bills)) {
          this.bills = bills
        }
        
        this.$hideLoading()
      } catch (error) {
        console.error('加载账单失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '加载失败，请稍后重试',
          icon: 'none'
        })
      }
    },
    
    // 添加账单
    async addBill() {
      if (!this.bill.amount || this.bill.amount <= 0) {
        this.$showToast({
          title: '请输入正确的金额',
          icon: 'none'
        })
        return
      }
      
      try {
        this.$showLoading({ title: '保存中...' })
        
        // 调用云函数添加账单
        await this.$cloud.callFunction('addBill', this.bill)
        
        // 重新加载账单
        await this.loadBills()
        
        // 重置表单
        this.bill = {
          amount: '',
          type: 2,
          category: '餐饮',
          date: new Date().toISOString().split('T')[0],
          description: ''
        }
        
        this.$hideLoading()
        this.$showToast({
          title: '保存成功',
          icon: 'success'
        })
      } catch (error) {
        console.error('保存账单失败:', error)
        this.$hideLoading()
        this.$showToast({
          title: '保存失败，请稍后重试',
          icon: 'none'
        })
      }
    }
  }
}
</script>

<style scoped>
.bill-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.bill-form {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
  margin-bottom: 30px;
}

.form-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 20px;
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
  min-height: 80px;
}

.type-selector {
  display: flex;
  gap: 10px;
}

.type-btn {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background-color: white;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s;
}

.type-btn.active {
  background-color: #ff6b6b;
  color: white;
  border-color: #ff6b6b;
}

.submit-btn {
  width: 100%;
  padding: 12px;
  background-color: #ff6b6b;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
  margin-top: 10px;
}

.submit-btn:hover {
  background-color: #ff5252;
}

.bill-list {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 20px;
}

.list-title {
  font-size: 18px;
  font-weight: bold;
  color: #333;
  margin-bottom: 15px;
}

.bill-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.bill-item:last-child {
  border-bottom: none;
}

.bill-info {
  flex: 1;
}

.bill-category {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.bill-description {
  font-size: 14px;
  color: #666;
  margin-bottom: 5px;
}

.bill-date {
  font-size: 12px;
  color: #999;
}

.bill-amount {
  font-size: 18px;
  font-weight: bold;
}

.bill-amount.expense {
  color: #ff6b6b;
}

.bill-amount.income {
  color: #4caf50;
}
</style>