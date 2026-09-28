import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_channel.dart';
import '../../domain/usecases/get_channels_use_case.dart';

sealed class ChannelsEvent {
  const ChannelsEvent();
}

final class ChannelsLoadRequested extends ChannelsEvent {
  const ChannelsLoadRequested();
}

sealed class ChannelsState {
  const ChannelsState();
}

final class ChannelsInitial extends ChannelsState {
  const ChannelsInitial();
}

final class ChannelsLoading extends ChannelsState {
  const ChannelsLoading();
}

final class ChannelsLoaded extends ChannelsState {
  const ChannelsLoaded(this.channels);

  final List<ChatChannel> channels;
}

final class ChannelsFailure extends ChannelsState {
  const ChannelsFailure(this.failure);

  final Failure failure;
}

final class ChannelsBloc extends Bloc<ChannelsEvent, ChannelsState> {
  ChannelsBloc(this._getChannels) : super(const ChannelsInitial()) {
    on<ChannelsLoadRequested>(_onLoad);
  }

  final GetChannelsUseCase _getChannels;

  Future<void> _onLoad(
    ChannelsLoadRequested event,
    Emitter<ChannelsState> emit,
  ) async {
    emit(const ChannelsLoading());
    final result = await _getChannels();
    final channels = result.channels;
    if (channels != null) {
      emit(ChannelsLoaded(channels));
    } else {
      emit(ChannelsFailure(result.failure ?? const UnknownFailure()));
    }
  }
}
