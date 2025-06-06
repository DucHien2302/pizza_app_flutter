part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class ShowPaymentSuccessNotification extends NotificationEvent {
  final String message;

  const ShowPaymentSuccessNotification({required this.message});

  @override
  List<Object> get props => [message];
}

class ShowPaymentFailureNotification extends NotificationEvent {
  final String message;

  const ShowPaymentFailureNotification({required this.message});

  @override
  List<Object> get props => [message];
}

class ShowGeneralNotification extends NotificationEvent {
  final String title;
  final String message;

  const ShowGeneralNotification({required this.title, required this.message});

  @override
  List<Object> get props => [title, message];
}

class ClearNotification extends NotificationEvent {}
