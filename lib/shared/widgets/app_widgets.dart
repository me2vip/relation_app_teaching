// 共享组件聚合（适配层）
//
// 源项目通过 `app_widgets.dart` 桶文件统一导出多个共享组件。教学模块仅实际
// 使用 `AppToast`，此处仅导出适配实现，避免引入未使用的依赖。

export 'app_toast.dart';
