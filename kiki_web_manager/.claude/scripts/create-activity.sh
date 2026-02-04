#!/bin/bash
# 快速创建 Android Activity 模板
# 使用方法：bash .claude/scripts/create-activity.sh MyActivity

ACTIVITY_NAME=$1
PACKAGE_PATH="com/yiqizuoye/yqpen"
BASE_PATH="yqPen/src/main/java/${PACKAGE_PATH}"

# 检查参数
if [ -z "$ACTIVITY_NAME" ]; then
    echo "❌ 错误：请提供 Activity 名称"
    echo "使用方法: bash .claude/scripts/create-activity.sh MyActivity"
    exit 1
fi

# 检查名称是否以 Activity 结尾
if [[ ! "$ACTIVITY_NAME" =~ Activity$ ]]; then
    echo "⚠️  警告：Activity 名称通常以 'Activity' 结尾"
    echo "建议使用：${ACTIVITY_NAME}Activity"
fi

# 生成 Kotlin 文件
cat > "${BASE_PATH}/${ACTIVITY_NAME}.kt" <<EOF
package com.yiqizuoye.yqpen

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.yiqizuoye.library.yqpensdk.utils.PenLog
import kotlinx.coroutines.launch

/**
 * ${ACTIVITY_NAME}
 *
 * 创建时间：$(date +%Y-%m-%d)
 * 描述：TODO 添加功能描述
 */
class ${ACTIVITY_NAME} : AppCompatActivity() {

    companion object {
        private const val TAG = "${ACTIVITY_NAME}"
        private const val EXTRA_DATA = "extra_data"

        /**
         * 创建 Intent
         */
        fun createIntent(context: Context, data: String = ""): Intent {
            return Intent(context, ${ACTIVITY_NAME}::class.java).apply {
                putExtra(EXTRA_DATA, data)
            }
        }
    }

    // TODO: 添加 ViewBinding
    // private lateinit var binding: Activity${ACTIVITY_NAME}Binding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // TODO: 初始化 ViewBinding
        // binding = Activity${ACTIVITY_NAME}Binding.inflate(layoutInflater)
        // setContentView(binding.root)

        PenLog.d(TAG, "onCreate")

        setupViews()
        loadData()
    }

    /**
     * 初始化视图
     */
    private fun setupViews() {
        // TODO: 设置视图监听器
        // binding.btnSubmit.setOnClickListener {
        //     handleSubmit()
        // }
    }

    /**
     * 加载数据
     */
    private fun loadData() {
        val data = intent.getStringExtra(EXTRA_DATA) ?: ""
        PenLog.d(TAG, "loadData: data=\$data")

        // TODO: 加载数据
        lifecycleScope.launch {
            try {
                // 异步操作
            } catch (e: Exception) {
                PenLog.e(TAG, "loadData error: \${e.message}")
            }
        }
    }

    override fun onStart() {
        super.onStart()
        PenLog.d(TAG, "onStart")
    }

    override fun onResume() {
        super.onResume()
        PenLog.d(TAG, "onResume")
    }

    override fun onPause() {
        super.onPause()
        PenLog.d(TAG, "onPause")
    }

    override fun onStop() {
        super.onStop()
        PenLog.d(TAG, "onStop")
    }

    override fun onDestroy() {
        super.onDestroy()
        // TODO: 清理资源
        PenLog.d(TAG, "onDestroy")
    }
}
EOF

# 生成布局文件（如果需要）
LAYOUT_PATH="yqPen/src/main/res/layout"
LAYOUT_NAME=$(echo "$ACTIVITY_NAME" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//')

cat > "${LAYOUT_PATH}/activity_${LAYOUT_NAME}.xml" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".${ACTIVITY_NAME}">

    <TextView
        android:id="@+id/tvTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="${ACTIVITY_NAME}"
        android:textSize="24sp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"/>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

echo "✅ Activity 创建成功！"
echo ""
echo "📁 已创建文件："
echo "   - ${BASE_PATH}/${ACTIVITY_NAME}.kt"
echo "   - ${LAYOUT_PATH}/activity_${LAYOUT_NAME}.xml"
echo ""
echo "📝 下一步："
echo "   1. 在 AndroidManifest.xml 中注册 Activity"
echo "   2. 启用 ViewBinding 并更新代码"
echo "   3. 实现业务逻辑"
