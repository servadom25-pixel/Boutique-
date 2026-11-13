-- E-TECH : permet au client de consulter uniquement le statut de sa commande
-- en fournissant son numéro de commande et le téléphone associé.
create or replace function public.get_order_status(
  p_order_number text,
  p_phone text
)
returns table(status text, payment_status text)
language sql
stable
security definer
set search_path = public
as $$
  select o.status, o.payment_status
  from public.orders o
  where o.order_number = p_order_number
    and o.customer_phone = p_phone
  limit 1;
$$;

revoke all on function public.get_order_status(text, text) from public;
grant execute on function public.get_order_status(text, text) to anon, authenticated;
