classDiagram
    direction TB

    class User {
        <<abstract>>
        +int id
        +string namaLengkap
        +string email
        +string noHp
        +string passwordHash
        +string role
        +string status
        +datetime createdAt
        +login()
        +logout()
        +updateProfile()
        +ubahPassword()
    }

    class Konsumen {
    }

    class UMKM {
        +string namaUsaha
        +string alamatUsaha
        +string kategoriUsaha
        +string emailUsaha
        +string dokumenNibSiup
        +string statusVerifikasi
        +ajukanVerifikasi()
    }

    User <|-- Konsumen
    User <|-- UMKM

    class Product {
        +int id
        +int umkmId
        +string nama
        +string deskripsi
        +decimal harga
        +int stok
        +string kategori
        +point lokasi
        +string[] fotoUrls
        +datetime createdAt
        +tambahProduk()
        +updateStok()
        +hapusProduk()
    }

    UMKM "1" --> "*" Product : mengelola

    class Cart {
        +int id
        +int userId
        +hitungTotal()
    }

    class CartItem {
        +int id
        +int cartId
        +int productId
        +int quantity
    }

    Konsumen "1" --> "1" Cart : memiliki
    Cart "1" --> "*" CartItem : berisi
    CartItem "*" --> "1" Product : merujuk

    class Order {
        +int id
        +int userId
        +string status
        +decimal totalAmount
        +datetime createdAt
        +buatPesanan()
        +updateStatus()
        +ajukanRefund()
    }

    class OrderItem {
        +int id
        +int orderId
        +int productId
        +int umkmId
        +int quantity
        +decimal hargaSatuan
    }

    Konsumen "1" --> "*" Order : membuat
    Order "1" --> "*" OrderItem : terdiri_dari
    OrderItem "*" --> "1" Product : merujuk

    class Payment {
        +int id
        +int orderId
        +string metode
        +string status
        +string midtransTransactionId
        +datetime expiredAt
        +prosesWebhook()
        +validasiSignature()
    }

    Order "1" --> "1" Payment : dibayar_via

    class Wallet {
        +int id
        +int userId
        +int saldoKoin
        +tambahKoin()
        +gunakanKoin()
        +cekKadaluwarsa()
    }

    class WalletTransaction {
        +int id
        +int walletId
        +string tipe
        +int jumlah
        +string deskripsi
        +datetime expiredAt
        +datetime createdAt
    }

    User "1" --> "1" Wallet : memiliki
    Wallet "1" --> "*" WalletTransaction : mencatat

    class Review {
        +int id
        +int orderId
        +int productId
        +int userId
        +int rating
        +string komentar
        +datetime createdAt
    }

    Konsumen "1" --> "*" Review : menulis
    Review "*" --> "1" Product : menilai

    class PriceRecommendation {
        +int id
        +int productId
        +decimal hargaSaran
        +decimal hargaMin
        +decimal hargaMax
        +int jumlahDianalisis
        +datetime createdAt
    }

    Product "1" --> "0..*" PriceRecommendation : mendapat

    class Notification {
        +int id
        +int userId
        +string tipe
        +string pesan
        +bool isRead
        +datetime createdAt
        +tandaiTerbaca()
    }

    User "1" --> "*" Notification : menerima

    class EmailVerificationToken {
        +int id
        +int userId
        +string token
        +datetime expiredAt
        +bool used
    }

    class PasswordResetToken {
        +int id
        +int userId
        +string tokenHash
        +datetime expiredAt
        +bool used
    }

    User "1" --> "0..*" EmailVerificationToken : punya
    User "1" --> "0..*" PasswordResetToken : punya
