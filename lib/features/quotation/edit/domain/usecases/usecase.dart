import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../data/model/send_data.dart';
import '../../data/repository_impl/repository_impl.dart';
import '../repositories/repository.dart';

abstract class EditQuotationUseCase {
  Future<HelperResponse<Quotation>> editQuotation(
    int id,
    EditQuotationSendData sendData,
  );
}

class EditQuotationUseCaseImpl implements EditQuotationUseCase {
  final EditQuotationRepository _repository = EditQuotationRepositoryImpl();

  @override
  Future<HelperResponse<Quotation>> editQuotation(
    int id,
    EditQuotationSendData sendData,
  ) {
    return _repository.editQuotation(id, sendData);
  }
}
