67	68
68	69
75	78
76	79
UPDATE bolls_verses SET text = ('') where translation='' and book=66  and chapter=21 and verse=12

UPDATE bolls_verses SET book=68 where translation='LXX' and book=67;
UPDATE bolls_verses SET book=69 where translation='LXX' and book=68;
UPDATE bolls_verses SET book=78 where translation='LXX' and book=75;
UPDATE bolls_verses SET book=79 where translation='LXX' and book=76;

-- left it as it is