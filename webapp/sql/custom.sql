use `isucari`;

update items set
  can_display_list = case status
    when 'on_sale' then 1
    when 'sold_out' then 1
    else 0
  end,
  root_category_id = case
    when category_id between 0 and 9 then 1
    when category_id between 10 and 19 then 10
    when category_id between 20 and 29 then 20
    when category_id between 30 and 39 then 30
    when category_id between 40 and 49 then 40
    when category_id between 50 and 59 then 50
    when category_id between 60 and 69 then 60
  end
;
create index item1 on items (seller_id, status, created_at);
create index item2 on items (buyer_id, status, created_at);
create index item3 on items (can_display_list, root_category_id, created_at);
create index item4 on items (can_display_list, created_at);
create index user1 on users (account_name);
