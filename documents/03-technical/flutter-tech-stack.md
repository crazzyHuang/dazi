# Flutter技术栈详细规划补充

## 1. Flutter技术栈详细设计

### 1.1 核心Flutter依赖

```yaml
# pubspec.yaml
name: tongpin_app
description: 同频搭子Flutter应用

dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.9
  
  # 网络请求
  dio: ^5.3.2
  retrofit: ^4.0.3
  
  # 本地存储
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  
  # UI组件
  material_symbols_icons: ^4.2719.3
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  
  # 地图和位置
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  
  # 实时通信
  socket_io_client: ^2.0.3+1
  
  # 图片处理
  image_picker: ^1.0.4
  photo_view: ^0.14.0
  
  # 路由导航
  go_router: ^12.1.3
  
  # 工具类
  intl: ^0.18.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  retrofit_generator: ^8.0.4
```

### 1.2 项目架构设计

```
lib/
├── main.dart                    # 应用入口
├── app/                        # 应用配置
│   ├── app.dart                # 主应用组件
│   ├── routes.dart             # 路由配置
│   └── theme.dart              # 主题配置
├── core/                       # 核心功能
│   ├── constants/              # 常量定义
│   ├── errors/                 # 错误处理
│   ├── network/                # 网络层
│   ├── storage/                # 本地存储
│   └── utils/                  # 工具函数
├── data/                       # 数据层
│   ├── datasources/            # 数据源
│   │   ├── local/              # 本地数据源
│   │   └── remote/             # 远程数据源
│   ├── models/                 # 数据模型
│   └── repositories/           # 仓储实现
├── domain/                     # 业务领域层
│   ├── entities/               # 业务实体
│   ├── repositories/           # 仓储接口
│   └── usecases/              # 用例
├── presentation/               # 表现层
│   ├── pages/                  # 页面
│   │   ├── auth/               # 认证相关页面
│   │   ├── home/               # 首页
│   │   ├── post/               # 搭子相关页面
│   │   ├── soul/               # 灵魂回响页面
│   │   ├── chat/               # 聊天页面
│   │   └── profile/            # 个人资料页面
│   ├── widgets/                # 通用组件
│   └── providers/              # 状态管理
└── l10n/                      # 国际化文件
```

## 2. 核心功能实现

### 2.1 网络层实现

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://api.tongpin.com/api/v1/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // 用户认证
  @POST("/auth/login")
  Future<AuthResponse> login(@Body() LoginRequest request);
  
  @POST("/auth/register/phone")
  Future<AuthResponse> register(@Body() RegisterRequest request);
  
  // 用户管理
  @GET("/users/me")
  Future<UserProfile> getProfile();
  
  @PUT("/users/me")
  Future<UserProfile> updateProfile(@Body() UpdateProfileRequest request);
  
  // 搭子邀约
  @GET("/posts")
  Future<PostListResponse> getPosts(@Queries() Map<String, dynamic> queries);
  
  @POST("/posts")
  Future<Post> createPost(@Body() CreatePostRequest request);
  
  @POST("/posts/{id}/join")
  Future<Application> joinPost(@Path("id") String postId, @Body() JoinRequest request);
  
  // 灵魂回响
  @GET("/soul/daily-question")
  Future<SoulQuestion> getDailyQuestion();
  
  @POST("/soul/answers")
  Future<SoulAnswer> submitAnswer(@Body() SubmitAnswerRequest request);
  
  @GET("/soul/answers")
  Future<List<SoulAnswer>> getAnswers(@Queries() Map<String, dynamic> queries);
}

// 网络拦截器
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.instance.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token过期，跳转到登录页
      NavigationService.instance.pushNamedAndClearStack('/login');
    }
    super.onError(err, handler);
  }
}
```

### 2.2 状态管理实现

```dart
// presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 认证状态
class AuthState {
  final bool isAuthenticated;
  final UserProfile? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserProfile? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthNotifier(this._authRepository, this._storageService) 
      : super(const AuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authRepository.login(phone, password);
      await _storageService.saveToken(response.tokens.accessToken);
      await _storageService.saveRefreshToken(response.tokens.refreshToken);
      
      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    await _storageService.clearTokens();
    state = const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storageService.getToken();
    if (token != null) {
      try {
        final user = await _authRepository.getProfile();
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
        );
      } catch (e) {
        await logout();
      }
    }
  }
}

// Provider定义
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(storageServiceProvider),
  );
});
```

### 2.3 页面实现示例

```dart
// presentation/pages/home/home_page.dart
class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('同频搭子'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: '首页'),
            Tab(icon: Icon(Icons.favorite), text: '灵魂'),
            Tab(icon: Icon(Icons.chat), text: '聊天'),
            Tab(icon: Icon(Icons.person), text: '我的'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PostListView(),
          SoulView(),
          ChatListView(),
          ProfileView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// presentation/pages/post/post_list_view.dart
class PostListView extends ConsumerWidget {
  const PostListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(postsProvider.future),
      child: postsAsync.when(
        data: (posts) => ListView.builder(
          itemCount: posts.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(postsProvider.future),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2.4 组件库设计

```dart
// presentation/widgets/post_card.dart
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({
    Key? key,
    required this.post,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post.user.avatarUrl ?? ''),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user.nickname,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          timeago.format(post.createdAt, locale: 'zh'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  CategoryChip(category: post.category),
                ],
              ),
              const SizedBox(height: 12),
              
              // 标题和内容
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (post.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // 图片展示
              if (post.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                ImageGallery(images: post.images),
              ],
              
              const SizedBox(height: 12),
              
              // 位置和时间信息
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.locationName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MM-dd HH:mm').format(post.activityTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${post.currentParticipants}/${post.maxParticipants}人',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  FilledButton(
                    onPressed: post.canJoin ? () => _showJoinDialog(context) : null,
                    child: Text(post.canJoin ? '申请加入' : '已满员'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => JoinPostDialog(post: post),
    );
  }
}
```

## 3. 下一步行动计划

基于Flutter技术栈，我建议按以下顺序进行开发：

### 3.1 第一阶段：基础架构搭建 (2-3周)
1. **项目初始化**：创建Flutter项目，配置基础依赖
2. **网络层开发**：实现API客户端和拦截器
3. **状态管理**：搭建Riverpod状态管理架构
4. **路由配置**：使用GoRouter配置应用路由
5. **主题系统**：实现Material Design 3主题

### 3.2 第二阶段：核心功能开发 (4-6周)
1. **用户认证**：登录、注册、资料管理
2. **搭子功能**：邀约发布、浏览、申请
3. **灵魂回响**：问题展示、回答提交
4. **基础聊天**：对话列表、消息发送
5. **地图集成**：位置选择、附近搭子

### 3.3 第三阶段：高级功能 (3-4周)
1. **实时通信**：WebSocket集成
2. **推送通知**：Firebase Cloud Messaging
3. **图片上传**：头像、聊天图片
4. **性能优化**：列表虚拟化、图片缓存
5. **离线支持**：本地存储、数据同步

### 3.4 第四阶段：测试和发布 (2-3周)
1. **单元测试**：核心业务逻辑测试
2. **集成测试**：API交互测试
3. **UI测试**：页面交互测试
4. **性能测试**：内存、电量优化
5. **应用发布**：App Store和Google Play

你觉得这个Flutter技术栈规划如何？有什么需要调整的地方吗？