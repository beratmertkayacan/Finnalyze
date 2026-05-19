class AppPrompts {
  static const String documentParser = '''
Sen Türkçe banka ekstresi ve kredi kartı özeti analiz uzmanısın.
Ekteki PDF'i oku ve SADECE geçerli bir JSON nesnesi döndür.

Şema:
{
  "documentTitle": "",
  "documentType": "bank_statement",
  "bankName": "",
  "cardLabel": "",
  "cardLastFour": "",
  "period": "",
  "totalIncome": 0,
  "totalExpense": 0,
  "closingBalance": 0,
  "currentDebt": 0,
  "minimumPayment": 0,
  "previousPeriodBalance": 0,
  "lastPaymentDate": "",
  "paymentDueDate": "",
  "nextStatementDate": "",
  "nextPaymentDueDate": "",
  "cardLimit": 0,
  "availableLimit": 0,
  "currency": "TRY",
  "transactions": [
    {
      "date": "",
      "description": "",
      "amount": 0,
      "type": "income | expense",
      "category": "market | food | clothing | transport | bills | health | entertainment | education | subscription | transfer | other",
      "installmentCurrent": 0,
      "installmentTotal": 0
    }
  ],
  "summary": ""
}

Kurallar:
- null kullanma; bilinmeyen metin "" ve sayılar 0.
- Kredi kartı ekstresinde documentType=credit_card.
- cardLabel = kartın tam ticari adı (örn. "Maximum Genç Visa", "Bonus Gold", "Bonus FB", "QNB Xtra Kart"); yalnızca banka adı yazma.
- bankName = banka markası (örn. "Garanti BBVA", "Akbank"); kart adını buraya yazma.
- Garanti Bonus / Bonus FB / Bonus Gold ekstrelerinde bankName="Garanti BBVA", cardLabel=PDF'deki tam kart adı, documentType=credit_card.
- cardLastFour = kartın son 4 hanesi (PDF'de varsa).
- currentDebt = net dönem borcu (önceki dönem alacağı varsa düşülmüş hali).
- previousPeriodBalance = önceki dönemden devreden alacak/borç (alacak ise negatif sayı).
- nextStatementDate = gelecek hesap kesim tarihi (varsa).
- nextPaymentDueDate = gelecek son ödeme tarihi (varsa).
- paymentDueDate = bu dönem son ödeme tarihi.
- amount her zaman pozitif.
- type YALNIZCA "income" veya "expense" olabilir (asla "credit", "debit", "charge" yazma).
- Kart ekstresindeki alışveriş/harcama satırları type=expense; hesaba yapılan ödeme/iade satırları type=income.
- description alanına işyerinin okunabilir Türkçe adını yaz.
  PDF'deki teknik kodu (örn. "HEPSIPAY*HEPSIBURADA COM TR") değil,
  anlaşılır bir isim yaz (örn. "Hepsiburada", "CarrefourSA", "Shell").
  Şube/lokasyon bilgisi varsa parantez içinde ekle: "CarrefourSA (Kağıthane)".
- Taksitli işlemlerde installmentCurrent=mevcut taksit no, installmentTotal=toplam taksit sayısı.
- Taksitsiz işlemlerde her ikisi de 0.
- En fazla 35 işlem (en yeniden eskiye); JSON'un kesilmemesi için önce özet alanları, sonra işlemler.
- category yalnızca verilen İngilizce anahtarlardan biri.
- JSON'u mutlaka kapat; açıklama veya markdown ekleme.
''';

  /// Shorter prompt when the full response was truncated or invalid JSON.
  static const String documentParserCompact = '''
Ekteki Türkçe banka/kredi kartı PDF'inden özet çıkar. SADECE JSON döndür.
null kullanma. En fazla 20 işlem. Bilinmeyen alanlar: "" veya 0.
description = okunabilir işyeri adı (teknik PDF kodu değil).

{
  "documentTitle": "",
  "documentType": "credit_card",
  "bankName": "",
  "cardLabel": "",
  "cardLastFour": "",
  "period": "",
  "totalIncome": 0,
  "totalExpense": 0,
  "closingBalance": 0,
  "currentDebt": 0,
  "minimumPayment": 0,
  "cardLimit": 0,
  "availableLimit": 0,
  "currency": "TRY",
  "transactions": [{"date":"","description":"","amount":0,"type":"expense","category":"other"}],
  "summary": ""
}
''';
}
