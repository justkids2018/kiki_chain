import SwiftUI

/// 个人中心视图
public struct ProfileView: View {
    @ObservedObject var authViewModel = AuthViewModel.shared
    @State private var showLoginSheet = false
    @State private var showSubscriptionSheet = false
    @State private var showSettingsSheet = false
    @State private var showMyInfo = false
    @State private var showFeedback = false
    @State private var showAbout = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // 个人信息卡片
                Section {
                    if authViewModel.isLoggedIn, let user = authViewModel.currentUser {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle().fill(Color.orange.opacity(0.15))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(user.nickname.isEmpty ? "小学者" : user.nickname)
                                        .font(.headline)

                                    if user.isVipActive {
                                        Text("VIP")
                                            .font(.caption2.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(Color.yellow.opacity(0.9)))
                                    }
                                }

                                Text(user.phone)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button {
                            showLoginSheet = true
                        } label: {
                            HStack(spacing: 16) {
                                Circle().fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("点击登录 / 注册")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("登录后同步学习进度与解锁全部场景")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // 学习统计
                Section("我的成就") {
                    HStack {
                        HStack(spacing: 7) {
                            CrystalStar(earned: true, size: 19)
                            Text("累计获得星星").foregroundColor(.orange)
                        }
                        Spacer()
                        Text("\(authViewModel.currentUser?.totalStars ?? 0) 颗")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                }

                Section("账户与帮助") {
                    Button { showMyInfo = true } label: { Label("我的资料", systemImage: "person.text.rectangle") }
                    Button { showFeedback = true } label: { Label("帮助与反馈", systemImage: "questionmark.bubble") }
                    Button { showAbout = true } label: { Label("关于 Hi Kiki", systemImage: "info.circle") }
                }

                // 会员与订阅
                Section("会员中心") {
                    Button {
                        showSubscriptionSheet = true
                    } label: {
                        HStack {
                            Label("VIP 会员状态", systemImage: "crown.fill")
                                .foregroundColor(.yellow)
                            Spacer()
                            Text(authViewModel.currentUser?.isVipActive == true ? "尊享会员 (已激活)" : "立即开通 >")
                                .foregroundColor(authViewModel.currentUser?.isVipActive == true ? .secondary : .orange)
                                .font(.subheadline.bold())
                        }
                    }
                }

                // 设置与关于
                Section {
                    Button {
                        showSettingsSheet = true
                    } label: {
                        HStack {
                            Label("声音与应用设置", systemImage: "gearshape.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if authViewModel.isLoggedIn {
                        Button(role: .destructive) {
                            authViewModel.logout()
                        } label: {
                            Text("退出登录")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("个人中心")
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .sheet(isPresented: $showSubscriptionSheet) {
                SubscriptionView()
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
            }
            .sheet(isPresented: $showMyInfo) { MyInfoView() }
            .sheet(isPresented: $showFeedback) { FeedbackView() }
            .sheet(isPresented: $showAbout) { AboutView() }
        }
    }
}
