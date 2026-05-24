class ClienteEntity {
  final String nombre;
  final String ciudad;
  final String correo;
  final int numCompras;
  final double totalGastado;
  final double ticketPromedio;

  const ClienteEntity({
    required this.nombre,
    required this.ciudad,
    required this.correo,
    required this.numCompras,
    required this.totalGastado,
    required this.ticketPromedio,
  });
}
