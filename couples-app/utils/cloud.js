// 云开发工具文件

// 云开发环境ID
const CLOUD_ENV = 'hao-yi-2g77ffe4ffd5f3b7'

// 初始化云开发
const init = () => {
  return new Promise((resolve, reject) => {
    // 检查是否在小程序环境
    if (typeof wx !== 'undefined' && wx.cloud) {
      // 小程序环境
      try {
        wx.cloud.init({
          env: CLOUD_ENV,
          traceUser: true
        })
        console.log('云开发初始化成功')
        resolve(true)
      } catch (error) {
        console.error('云开发初始化失败:', error)
        reject(error)
      }
    } else if (typeof uni !== 'undefined' && uni.cloud) {
      // Uniapp环境
      try {
        uni.cloud.init({
          env: CLOUD_ENV,
          traceUser: true
        })
        console.log('云开发初始化成功')
        resolve(true)
      } catch (error) {
        console.error('云开发初始化失败:', error)
        reject(error)
      }
    } else if (typeof uni !== 'undefined' && uniCloud) {
      // H5环境使用uniCloud
      try {
        uniCloud.init({
          provider: 'tcb',
          env: CLOUD_ENV
        })
        console.log('uniCloud初始化成功')
        resolve(true)
      } catch (error) {
        console.error('uniCloud初始化失败:', error)
        reject(error)
      }
    } else {
      const error = new Error('云开发环境未就绪')
      console.error('云开发环境未就绪')
      reject(error)
    }
  })
}

// 获取数据库实例
const getDatabase = () => {
  if (typeof wx !== 'undefined' && wx.cloud) {
    return wx.cloud.database()
  } else if (typeof uni !== 'undefined' && uni.cloud) {
    return uni.cloud.database()
  } else if (typeof uni !== 'undefined' && uniCloud) {
    return uniCloud.database()
  }
  return null
}

// 获取存储实例
const getStorage = () => {
  if (typeof wx !== 'undefined' && wx.cloud) {
    return wx.cloud.getStorage()
  } else if (typeof uni !== 'undefined' && uni.cloud) {
    return uni.cloud.getStorage()
  } else if (typeof uni !== 'undefined' && uniCloud) {
    return uniCloud.getStorage()
  }
  return null
}

// 调用云函数
const callFunction = (name, data) => {
  return new Promise((resolve, reject) => {
    if (typeof wx !== 'undefined' && wx.cloud) {
      wx.cloud.callFunction({
        name,
        data,
        success: (res) => {
          if (res.result && res.result.code === 0) {
            resolve(res.result.data)
          } else {
            reject(new Error(res.result?.message || '云函数调用失败'))
          }
        },
        fail: (error) => {
          console.error('云函数调用失败:', error)
          reject(error)
        }
      })
    } else if (typeof uni !== 'undefined' && uni.cloud) {
      uni.cloud.callFunction({
        name,
        data,
        success: (res) => {
          if (res.result && res.result.code === 0) {
            resolve(res.result.data)
          } else {
            reject(new Error(res.result?.message || '云函数调用失败'))
          }
        },
        fail: (error) => {
          console.error('云函数调用失败:', error)
          reject(error)
        }
      })
    } else if (typeof uni !== 'undefined' && uniCloud) {
      uniCloud.callFunction({
        name,
        data
      }).then((res) => {
        if (res.result && res.result.code === 0) {
          resolve(res.result.data)
        } else {
          reject(new Error(res.result?.message || '云函数调用失败'))
        }
      }).catch((error) => {
        console.error('云函数调用失败:', error)
        reject(error)
      })
    } else {
      const error = new Error('云函数调用失败：环境未就绪')
      reject(error)
    }
  })
}

// 数据库操作封装
const db = {
  // 查询数据
  query: (collection, condition = {}) => {
    const database = getDatabase()
    if (!database) {
      return Promise.reject(new Error('数据库未初始化'))
    }
    return database.collection(collection).where(condition).get()
  },
  
  // 添加数据
  add: (collection, data) => {
    const database = getDatabase()
    if (!database) {
      return Promise.reject(new Error('数据库未初始化'))
    }
    return database.collection(collection).add({ data })
  },
  
  // 更新数据
  update: (collection, id, data) => {
    const database = getDatabase()
    if (!database) {
      return Promise.reject(new Error('数据库未初始化'))
    }
    return database.collection(collection).doc(id).update({ data })
  },
  
  // 删除数据
  remove: (collection, id) => {
    const database = getDatabase()
    if (!database) {
      return Promise.reject(new Error('数据库未初始化'))
    }
    return database.collection(collection).doc(id).remove()
  }
}

// 存储操作封装
const storage = {
  // 上传文件
  uploadFile: (cloudPath, filePath) => {
    return new Promise((resolve, reject) => {
      if (typeof wx !== 'undefined' && wx.cloud) {
        wx.cloud.uploadFile({
          cloudPath,
          filePath,
          success: resolve,
          fail: reject
        })
      } else if (typeof uni !== 'undefined' && uni.cloud) {
        uni.cloud.uploadFile({
          cloudPath,
          filePath,
          success: resolve,
          fail: reject
        })
      } else if (typeof uni !== 'undefined' && uniCloud) {
        uniCloud.uploadFile({
          cloudPath,
          filePath
        }).then(resolve).catch(reject)
      } else {
        reject(new Error('存储环境未就绪'))
      }
    })
  },
  
  // 下载文件
  downloadFile: (fileID) => {
    return new Promise((resolve, reject) => {
      if (typeof wx !== 'undefined' && wx.cloud) {
        wx.cloud.downloadFile({
          fileID,
          success: resolve,
          fail: reject
        })
      } else if (typeof uni !== 'undefined' && uni.cloud) {
        uni.cloud.downloadFile({
          fileID,
          success: resolve,
          fail: reject
        })
      } else if (typeof uni !== 'undefined' && uniCloud) {
        uniCloud.downloadFile({
          fileID
        }).then(resolve).catch(reject)
      } else {
        reject(new Error('存储环境未就绪'))
      }
    })
  },
  
  // 删除文件
  deleteFile: (fileList) => {
    return new Promise((resolve, reject) => {
      if (typeof wx !== 'undefined' && wx.cloud) {
        wx.cloud.deleteFile({
          fileList,
          success: resolve,
          fail: reject
        })
      } else if (typeof uni !== 'undefined' && uni.cloud) {
        uni.cloud.deleteFile({
          fileList,
          success: resolve,
          fail: reject
        })
      } else if (typeof uni !== 'undefined' && uniCloud) {
        uniCloud.deleteFile({
          fileList
        }).then(resolve).catch(reject)
      } else {
        reject(new Error('存储环境未就绪'))
      }
    })
  }
}

// 导出云开发工具方法
export {
  init,
  getDatabase,
  getStorage,
  callFunction,
  db,
  storage
}