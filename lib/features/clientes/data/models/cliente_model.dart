import '../../domain/entities/cliente_entity.dart';

class ClienteModel extends ClienteEntity {
  const ClienteModel({
    required super.nombre,
    required super.ciudad,
    required super.correo,
    required super.numCompras,
    required super.totalGastado,
    required super.ticketPromedio,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      nombre: json['nombre'] ?? 'Desconocido',
      ciudad: json['ciudad'] ?? 'Sin ciudad',
      correo: json['correo'] ?? 'Sin correo',
      numCompras: (json['num_compras'] as num?)?.toInt() ?? 0,
      totalGastado: (json['total_gastado'] as num?)?.toDouble() ?? 0.0,
      ticketPromedio: (json['ticket_promedio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
