import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/komplain_repository.dart';
import '../../data/repositories/pengumuman_repository.dart';
import '../../data/repositories/repository_exception.dart';
import '../../data/services/fcm_service.dart';
import 'ticket_fcm_event.dart';
import 'ticket_fcm_state.dart';

class TicketFcmBloc extends Bloc<TicketFcmEvent, TicketFcmState> {
  TicketFcmBloc({
    KomplainRepository? komplainRepository,
    PengumumanRepository? pengumumanRepository,
    FcmService? fcmService,
  })  : _komplainRepository = komplainRepository ?? KomplainRepository(),
        _pengumumanRepository =
            pengumumanRepository ?? PengumumanRepository(),
        _fcmService = fcmService ?? FcmService.instance,
        super(const TicketFcmInitial()) {
    on<TicketRequested>(_onTicketRequested);
    on<TicketCreated>(_onTicketCreated);
    on<TicketUpdated>(_onTicketUpdated);
    on<AnnouncementBroadcasted>(_onAnnouncementBroadcasted);
    on<AnnouncementUpdated>(_onAnnouncementUpdated);
    on<AnnouncementDeleted>(_onAnnouncementDeleted);
    on<FcmMessageReceived>(_onFcmMessageReceived);

    _fcmSubscription = _fcmService.onMessageStream.listen((payload) {
      add(FcmMessageReceived(payload));
    });
  }

  final KomplainRepository _komplainRepository;
  final PengumumanRepository _pengumumanRepository;
  final FcmService _fcmService;
  StreamSubscription<FcmNotificationPayload>? _fcmSubscription;

  Future<void> _onTicketRequested(
    TicketRequested event,
    Emitter<TicketFcmState> emit,
  ) async {
    emit(const TicketFcmLoading());
    try {
      final komplain = await _komplainRepository.fetchDaftarKomplain();
      final pengumuman = await _pengumumanRepository.fetchDaftarPengumuman();
      final token = await _fcmService.getFcmToken();
      emit(
        TicketFcmLoaded(
          daftarKomplain: komplain,
          daftarPengumuman: pengumuman,
          fcmToken: token,
        ),
      );
    } on RepositoryException catch (e) {
      emit(TicketFcmFailure(e.message));
    } catch (e) {
      emit(TicketFcmFailure('Gagal memuat data tiket & pengumuman: $e'));
    }
  }

  Future<void> _onTicketCreated(
    TicketCreated event,
    Emitter<TicketFcmState> emit,
  ) async {
    emit(const TicketFcmLoading());
    try {
      await _komplainRepository.buatKomplain(
        idUser: event.idUser,
        idKamar: event.idKamar,
        kodeKamar: event.kodeKamar,
        namaPenghuni: event.namaPenghuni,
        kategoriFasilitas: event.kategoriFasilitas,
        judulKomplain: event.judulKomplain,
        deskripsiKomplain: event.deskripsiKomplain,
        fotoKerusakan: event.fotoKerusakan,
      );
      final komplain = await _komplainRepository.fetchDaftarKomplain();
      final pengumuman = await _pengumumanRepository.fetchDaftarPengumuman();
      emit(
        TicketFcmLoaded(
          daftarKomplain: komplain,
          daftarPengumuman: pengumuman,
          actionMessage:
              'Laporan aduan terkirim, menunggu tindakan pengelola.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(TicketFcmFailure(e.message));
    } catch (e) {
      emit(TicketFcmFailure('Gagal mengirim laporan aduan: $e'));
    }
  }

  Future<void> _onTicketUpdated(
    TicketUpdated event,
    Emitter<TicketFcmState> emit,
  ) async {
    emit(const TicketFcmLoading());
    try {
      final updated = await _komplainRepository.updateStatusKomplain(
        idKomplain: event.idKomplain,
        statusBaru: event.statusBaru,
        catatanTeknisi: event.catatanTeknisi,
      );
      final komplain = await _komplainRepository.fetchDaftarKomplain();
      final pengumuman = await _pengumumanRepository.fetchDaftarPengumuman();
      emit(
        TicketFcmLoaded(
          daftarKomplain: komplain,
          daftarPengumuman: pengumuman,
          actionMessage:
              'Status tiket ${updated.kodeTiket} diperbarui & notifikasi FCM dikirim.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(TicketFcmFailure(e.message));
    } catch (e) {
      emit(TicketFcmFailure('Gagal memperbarui status komplain: $e'));
    }
  }

  Future<void> _onAnnouncementBroadcasted(
    AnnouncementBroadcasted event,
    Emitter<TicketFcmState> emit,
  ) async {
    emit(const TicketFcmLoading());
    try {
      await _pengumumanRepository.kirimBroadcast(
        judul: event.judul,
        isi: event.isi,
        kategori: event.kategori,
        pin: event.pin,
      );
      final komplain = await _komplainRepository.fetchDaftarKomplain();
      final pengumuman = await _pengumumanRepository.fetchDaftarPengumuman();
      emit(
        TicketFcmLoaded(
          daftarKomplain: komplain,
          daftarPengumuman: pengumuman,
          actionMessage:
              'Pengumuman berhasil disiarkan ke seluruh penghuni via FCM.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(TicketFcmFailure(e.message));
    } catch (e) {
      emit(TicketFcmFailure('Gagal mengirim broadcast pengumuman: $e'));
    }
  }

  Future<void> _onAnnouncementUpdated(
    AnnouncementUpdated event,
    Emitter<TicketFcmState> emit,
  ) async {
    emit(const TicketFcmLoading());
    try {
      await _pengumumanRepository.editPengumuman(
        idPengumuman: event.idPengumuman,
        judul: event.judul,
        isi: event.isi,
        kategori: event.kategori,
        pin: event.pin,
      );
      final komplain = await _komplainRepository.fetchDaftarKomplain();
      final pengumuman = await _pengumumanRepository.fetchDaftarPengumuman();
      emit(
        TicketFcmLoaded(
          daftarKomplain: komplain,
          daftarPengumuman: pengumuman,
          actionMessage: 'Pengumuman berhasil diperbarui.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(TicketFcmFailure(e.message));
    } catch (e) {
      emit(TicketFcmFailure('Gagal memperbarui pengumuman: $e'));
    }
  }

  Future<void> _onAnnouncementDeleted(
    AnnouncementDeleted event,
    Emitter<TicketFcmState> emit,
  ) async {
    emit(const TicketFcmLoading());
    try {
      await _pengumumanRepository.hapusPengumuman(event.idPengumuman);
      final komplain = await _komplainRepository.fetchDaftarKomplain();
      final pengumuman = await _pengumumanRepository.fetchDaftarPengumuman();
      emit(
        TicketFcmLoaded(
          daftarKomplain: komplain,
          daftarPengumuman: pengumuman,
          actionMessage: 'Pengumuman berhasil dihapus.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(TicketFcmFailure(e.message));
    } catch (e) {
      emit(TicketFcmFailure('Gagal menghapus pengumuman: $e'));
    }
  }

  void _onFcmMessageReceived(
    FcmMessageReceived event,
    Emitter<TicketFcmState> emit,
  ) {
    final current = state;
    if (current is TicketFcmLoaded) {
      emit(current.copyWith(latestNotification: event.payload));
    }
  }

  @override
  Future<void> close() async {
    await _fcmSubscription?.cancel();
    return super.close();
  }
}