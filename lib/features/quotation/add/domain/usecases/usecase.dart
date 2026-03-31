import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../data/model/send_data.dart';
import '../../data/repository_impl/repository_impl.dart';
import '../repositories/repository.dart';

abstract class AddQuotationUseCase {
  Future<HelperResponse<Quotation>> addQuotation(QuotationSendData sendData);
}

class AddQuotationUseCaseImpl implements AddQuotationUseCase {
  final AddQuotationRepository _repository = AddQuotationRepositoryImpl();

  @override
  Future<HelperResponse<Quotation>> addQuotation(
      QuotationSendData sendData) {
    return _repository.addQuotation(sendData);
  }
}
