import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<ShowPaymentSuccessNotification>((event, emit) {
      emit(NotificationShown(
        type: NotificationType.paymentSuccess,
        message: event.message,
        title: 'Thanh toán thành công!',
      ));
    });

    on<ShowPaymentFailureNotification>((event, emit) {
      emit(NotificationShown(
        type: NotificationType.paymentFailure,
        message: event.message,
        title: 'Thanh toán thất bại!',
      ));
    });

    on<ShowGeneralNotification>((event, emit) {
      emit(NotificationShown(
        type: NotificationType.general,
        message: event.message,
        title: event.title,
      ));
    });

    on<ClearNotification>((event, emit) {
      emit(NotificationInitial());
    });
  }
}
