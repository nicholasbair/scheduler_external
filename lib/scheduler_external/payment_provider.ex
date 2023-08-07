defmodule SchedulerExternal.Integrations.PaymentProvider do

  def build_payment_params(cost, title, email) do
    url = SchedulerExternalWeb.Endpoint.url()

   %{
      line_items: [
        %{
          price_data: %{
            currency: "usd",
            unit_amount: cost * 100, # 100 == $1.00
            product_data: %{
              name: title,
            },
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: url <> "/bookings/payment/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: url <> "/bookings/payment/cancel?session_id={CHECKOUT_SESSION_ID}",
      customer_email: email,
    }
  end
end
