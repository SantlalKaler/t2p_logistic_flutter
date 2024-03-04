enum UserType{
  delivery_boy,
  delivery_partner,
  lp_head,
  lp_manager
}

enum OrderType{
  pickup,
  deliver
}

enum T2POrderType{
  T2P,
  AF2AP // Any Food 2 Any Place
}

enum PaymentType{
  COD,
  Link,
  QR,
  Online
}

enum PhonePePaymentStatus{
  PAYMENT_SUCCESS,
  PAYMENT_PENDING,
  PAYMENT_ERROR,
  INTERNAL_SERVER_ERROR
}

enum PrintInvoiceType{
  partner_today_order_invoice,
  partner_today_order_by_product_invoice,
  partner_tomorrow_order_invoice,
  partner_tomorrow_order_by_product_invoice
}

enum CodStatus{
  pending,
  reject,
  accepted,
  submitted
}