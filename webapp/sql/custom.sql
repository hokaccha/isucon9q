use `isucari`;

create index item1 on items (seller_id, status, created_at);
create index item2 on items (buyer_id, status, created_at);
