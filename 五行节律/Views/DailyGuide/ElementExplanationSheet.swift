import SwiftUI

/// 五行解释Sheet视图
struct ElementExplanationSheet: View {
    let element: FiveElement
    @Environment(\.dismiss) var dismiss
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 元素图标
                    ZStack {
                        Circle()
                            .fill(element.gradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: element.color.opacity(0.5), radius: 20, x: 0, y: 10)

                        Image(systemName: element.iconName)
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)

                    // 元素名称
                    Text(element.rawValue)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(element.color)

                    // 解释内容
                    Text(element.explanation)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 40)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        element.color.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("今日五行")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(element.color)
                    .accessibilityLabel("关闭五行解释")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ElementExplanationSheet(element: .wood)
}
