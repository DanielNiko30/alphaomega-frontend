abstract class KategoriEvent {}

class FetchKategori extends KategoriEvent {}

class AddKategori extends KategoriEvent {
  final String namaKategori;
  AddKategori(this.namaKategori);
}

class EditKategori extends KategoriEvent {
  final String idKategori;
  final String namaBaru;
  EditKategori(this.idKategori, this.namaBaru);
}

// 🔹 Event baru untuk search
class SearchKategoriByName extends KategoriEvent {
  final String query;
  SearchKategoriByName(this.query);
}

class DeleteKategori extends KategoriEvent {
  final String idKategori;

  DeleteKategori(this.idKategori);
}
