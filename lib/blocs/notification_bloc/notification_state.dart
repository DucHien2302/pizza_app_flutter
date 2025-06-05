part of 'notification_bloc.dart';

enum NotificationType { paymentSuccess, paymentFailure, general }

sealed class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object> get props => [];
}

final class NotificationInitial extends NotificationState {}

final class NotificationShown extends NotificationState {
  final NotificationType type;
  final String title;
  final String message;

  const NotificationShown({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  List<Object> get props => [type, title, message];
}
