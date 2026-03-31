import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../domain/repositories/repository.dart';
import '../data_source/data_source.dart';
import '../model/send_data.dart';

class EditQuotationRepositoryImpl implements EditQuotationRepository {
  final EditQuotationDataSource _dataSource = EditQuotationDataSourceImpl();

  @override
  Future<HelperResponse<Quotation>> editQuotation(
    int id,
    EditQuotationSendData sendData,
  ) {
    return _dataSource.editQuotation(id, sendData);
  }
}
