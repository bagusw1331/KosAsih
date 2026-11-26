import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/pembayaran_repository.dart';
import '../../data/repositories/repository_exception.dart';
import 'payment_verify_event.dart';
import 'payment_verify_state.dart';

class PaymentVerifyBloc extends Bloc<PaymentVerifyEvent, PaymentVerifyState> {
  PaymentVerifyBloc({PembayaranRepository? repository})
      : _repository = repository ?? PembayaranRepository(),
        super(const PaymentVerifyInitial()) {
    on<PaymentVerificationRequested>(_onVerificationRequested);
    on<PaymentProofSubmitted>(_onProofSubmitted);
    on<PaymentApproved>(_onApproved);
    on<PaymentRejected>(_onRejected);
  }

  final PembayaranRepository _repository;

  Future<void> _onVerificationRequested(
    PaymentVerificationRequested event,
    Emitter<PaymentVerifyState> emit,
  ) async {
    emit(const PaymentVerifyLoading());
    try {
      final list = await _repository.fetchDaftarPembayaran();
      emit(PaymentVerifyLoaded(daftarPembayaran: list));
    } on RepositoryException catch (e) {
      emit(PaymentVerifyFailure(e.message));
    } catch (e) {
      emit(PaymentVerifyFailure('Gagal memuat data pembayaran: $e'));
    }
  }

  Future<void> _onProofSubmitted(
    PaymentProofSubmitted event,
    Emitter<PaymentVerifyState> emit,
  ) async {
    emit(const PaymentVerifyLoading());
    try {
      await _repository.uploadBuktiPembayaran(
        idPembayaran: event.idPembayaran,
        fileBukti: event.fileBukti,
        metodePembayaran: event.metodePembayaran,
      );
      final list = await _repository.fetchDaftarPembayaran();
      emit(
        PaymentVerifyLoaded(
          daftarPembayaran: list,
          actionMessage:
              'Bukti pembayaran terkirim, menunggu verifikasi pemilik.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(PaymentVerifyFailure(e.message));
    } catch (e) {
      emit(PaymentVerifyFailure('Gagal mengunggah bukti pembayaran: $e'));
    }
  }

  Future<void> _onApproved(
    PaymentApproved event,
    Emitter<PaymentVerifyState> emit,
  ) async {
    emit(const PaymentVerifyLoading());
    try {
      final updated =
          await _repository.verifikasiPembayaran(event.idPembayaran);
      final list = await _repository.fetchDaftarPembayaran();
      emit(
        PaymentVerifyLoaded(
          daftarPembayaran: list,
          actionMessage:
              'Pembayaran ${updated.kodeKamar} diverifikasi & E-Kuitansi diterbitkan.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(PaymentVerifyFailure(e.message));
    } catch (e) {
      emit(PaymentVerifyFailure('Gagal memverifikasi pembayaran: $e'));
    }
  }

  Future<void> _onRejected(
    PaymentRejected event,
    Emitter<PaymentVerifyState> emit,
  ) async {
    emit(const PaymentVerifyLoading());
    try {
      final updated = await _repository.tolakPembayaran(
        idPembayaran: event.idPembayaran,
        alasanPenolakan: event.alasanPenolakan,
      );
      final list = await _repository.fetchDaftarPembayaran();
      emit(
        PaymentVerifyLoaded(
          daftarPembayaran: list,
          actionMessage: 'Bukti pembayaran ${updated.kodeKamar} ditolak.',
        ),
      );
    } on RepositoryException catch (e) {
      emit(PaymentVerifyFailure(e.message));
    } catch (e) {
      emit(PaymentVerifyFailure('Gagal menolak bukti pembayaran: $e'));
    }
  }
}