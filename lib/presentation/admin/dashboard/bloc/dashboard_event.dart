import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String startDate;
  final String endDate;

  const LoadDashboard({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
