import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../data/model/send_data.dart';

abstract class EditQuotationRepository {
  Future<HelperResponse<Quotation>> editQuotation(
    int id,
    EditQuotationSendData sendData,
  );
}
