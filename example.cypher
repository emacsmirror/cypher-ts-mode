// 1st query
MATCH (cc: Customer) 
      -[:BOUGHT]-> (ci: Invoice { invoiceId: 1234 } ) 
      -[:CONTAINS]-> (ca)
      <-[:CONTAINS]- (oi: Invoice)
      -[:CONTAINS]-> (ra)
WHERE
  oi <> ci // different invoice
  AND ra <> ca // different article (implied by path below)
  AND NOT (cc) -[:BOUGHT]-> () -[:CONTAINS]-> (ra) // not bought by cc
  AND oi.date + duration("P3M") >= date() // in the last 3 months
RETURN ra

// 2nd query
MATCH (m:Module)
      <-[:IMPORTS]-(:ModuleGroup)
      <-[:CONTAINS*1..]-(pos:ProgramOfStudy{shortcut:"MSc WebSci 2017"})
WHERE NOT (m)
      <-[:IMPORTS]-(:ModuleGroup)
      <-[:CONTAINS*1..]-(pos:ProgramOfStudy{shortcut:"MSc CV 2019"})
AND m.Name CONTAINS "Software" AND pos.mandatory == false
WITH mg.name AS mgName,
     SUM(m.creditPoints) AS sumCP
RETURN m.ID,
       m.Name
ORDER BY m.Name;


