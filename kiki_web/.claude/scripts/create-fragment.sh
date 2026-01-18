#!/bin/bash
# 快速创建 Android Fragment 模板
# 使用方法：bash .claude/scripts/create-fragment.sh MyFragment

FRAGMENT_NAME=$1
PACKAGE_PATH="com/yiqizuoye/yqpen"
BASE_PATH="yqPen/src/main/java/${PACKAGE_PATH}"

# 检查参数
if [ -z "$FRAGMENT_NAME" ]; then
    echo "❌ 错误：请提供 Fragment 名称"
    echo "使用方法: bash .claude/scripts/create-fragment.sh MyFragment"
    exit 1
fi

# 检查名称是否以 Fragment 结尾
if [[ ! "$FRAGMENT_NAME" =~ Fragment$ ]]; then
    echo "⚠️  警告：Fragment 名称通常以 'Fragment' 结尾"
    echo "建议使用：${FRAGMENT_NAME}Fragment"
fi

# 生成 Kotlin 文件
cat > "${BASE_PATH}/${FRAGMENT_NAME}.kt" <<EOF
package com.yiqizuoye.yqpen

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.yiqizuoye.library.yqpensdk.utils.PenLog
import kotlinx.coroutines.launch

/**
 * ${FRAGMENT_NAME}
 *
 * 创建时间：$(date +%Y-%m-%d)
 * 描述：TODO 添加功能描述
 */
class ${FRAGMENT_NAME} : Fragment() {

    companion object {
        private const val TAG = "${FRAGMENT_NAME}"
        private const val ARG_DATA = "arg_data"

        /**
         * 创建实例
         */
        fun newInstance(data: String = ""): ${FRAGMENT_NAME} {
            return ${FRAGMENT_NAME}().apply {
                arguments = Bundle().apply {
                    putString(ARG_DATA, data)
                }
            }
        }
    }

    // ViewBinding（避免内存泄漏）
    // private var _binding: Fragment${FRAGMENT_NAME}Binding? = null
    // private val binding get() = _binding!!

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        PenLog.d(TAG, "onCreate")

        // 获取参数
        arguments?.let {
            val data = it.getString(ARG_DATA, "")
            PenLog.d(TAG, "onCreate: data=\$data")
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        PenLog.d(TAG, "onCreateView")

        // TODO: 初始化 ViewBinding
        // _binding = Fragment${FRAGMENT_NAME}Binding.inflate(inflater, container, false)
        // return binding.root

        // 临时返回
        return inflater.inflate(android.R.layout.simple_list_item_1, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        PenLog.d(TAG, "onViewCreated")

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
        // 使用 viewLifecycleOwner（重要！）
        viewLifecycleOwner.lifecycleScope.launch {
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

    override fun onDestroyView() {
        super.onDestroyView()
        // TODO: 清理 ViewBinding（避免内存泄漏）
        // _binding = null
        PenLog.d(TAG, "onDestroyView")
    }

    override fun onDestroy() {
        super.onDestroy()
        PenLog.d(TAG, "onDestroy")
    }
}
EOF

# 生成布局文件（如果需要）
LAYOUT_PATH="yqPen/src/main/res/layout"
LAYOUT_NAME=$(echo "$FRAGMENT_NAME" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//')

cat > "${LAYOUT_PATH}/fragment_${LAYOUT_NAME}.xml" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".${FRAGMENT_NAME}">

    <TextView
        android:id="@+id/tvTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="${FRAGMENT_NAME}"
        android:textSize="20sp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"/>

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

echo "✅ Fragment 创建成功！"
echo ""
echo "📁 已创建文件："
echo "   - ${BASE_PATH}/${FRAGMENT_NAME}.kt"
echo "   - ${LAYOUT_PATH}/fragment_${LAYOUT_NAME}.xml"
echo ""
echo "📝 下一步："
echo "   1. 启用 ViewBinding 并更新代码"
echo "   2. 在 Activity 中添加 Fragment"
echo "   3. 实现业务逻辑"
echo ""
echo "⚠️  重要提示："
echo "   - Fragment 中使用 viewLifecycleOwner.lifecycleScope"
echo "   - onDestroyView 中清理 _binding（避免内存泄漏）"
