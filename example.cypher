//
// Some query
MATCH (cc: Customer)
      -[:BOUGHT]->(ci: Invoice { invoiceId: 1234 } ) 
      -[:CONTAINS]->(ca)
      <-[:CONTAINS]-(oi: Invoice)
      -[:CONTAINS]->(ra)
WHERE oi <> ci // different invoice
      AND ra <> ca // different article (implied by path below)
      AND NOT (cc)
	      -[:BOUGHT]->()
	      -[:CONTAINS]->(ra) // not bought by cc
      AND oi.date + duration("P3M") >= date() // in the last 3 months
RETURN ra,
       ci.invoiceId;

//
// And another query
MATCH (m:Module)
      <-[:IMPORTS]-(:ModuleGroup)
      <-[:CONTAINS*1..]-(pos:ProgramOfStudy{shortcut:"MSc WebSci 2017"})
WHERE NOT (m)
	  <-[:IMPORTS]-(:ModuleGroup)
	  <-[:CONTAINS*1..]-(pos:ProgramOfStudy{shortcut:"MSc CV 2019"}
      AND m.Name CONTAINS "Software"
      AND pos.mandatory == false
WITH mg.name AS mgName,
     SUM(m.creditPoints) AS sumCP
RETURN m.ID,
       m.Name
ORDER BY m.Name;

// 
// 3rd query
MATCH (n) DETACH DELETE n

CREATE (alice:Customer {name:'Alice'}),
       (bob:Customer {name:'Bob'}),
       (charlie:Customer {name:'Charlie'}),
       (a1:Article {name:'Laptop', price:500.00 }),
       (a2:Article {name:'Mouse', price:15.00 }),
       (a3:Article {name:'Battery', price:80.00 }),
       (a4:Article {name:'Operating System', price:55.00 }),
       (a5:Article {name:'Backpack', price:123.00 }),
       (i1:Invoice {invoiceId:1234, date:date()}),
       (i2:Invoice {invoiceId:2345, date:date()}),
       (i3:Invoice {invoiceId:3456, date:date()})

CREATE (alice) -[:BOUGHT]-> (i1),
       (i1) -[:CONTAINS {quantity: 1}]-> (a1),
       (i2) -[:CONTAINS {quantity: 1}]-> (a2),
       (bob) -[:BOUGHT]-> (i2),
       (i2) -[:CONTAINS {quantity: 1}]-> (a1),
       (i2) -[:CONTAINS {quantity: 1}]-> (a3),
       (i2) -[:CONTAINS {quantity: 1}]-> (a5),
       (alice) -[:BOUGHT]-> (i3),
       (i3) -[:CONTAINS {quantity: 1 }]-> (a2),
       (i3) -[:CONTAINS {quantity: 2}]-> (a3);


// Recommender-Query

MATCH (cc: Customer) 
      -[:BOUGHT]-> (ci: Invoice { invoiceId: 1234 } ) 
      -[:CONTAINS]-> (ca)
      <-[:CONTAINS]- (oi: Invoice)
      -[:CONTAINS]-> (ra)
WHERE oi <> ci          // different invoice
      AND ra <> ca      // different article (implied by path below)
      AND NOT (cc) -[:BOUGHT]-> () -[:CONTAINS]-> (ra)   // not bought by cc
      AND oi.date + duration("P3M") >= date() // in the last 3 months
RETURN ra;

// a. Determine module ID and names of all modules with names that contain the word 'Software'.
MATCH (m:Module)
WHERE m.name CONTAINS "Software"
RETURN m.ID, m.Name

// b. Report for all organizaional units: the shortcut, the unit name, and the full name and email address of the heads.
MATCH (ou:OrganizationalUnit)<-[:LEADS]-(p:Person)
RETURN ou.shortcut, ou.name, p.firstName, p.lastName, p.email

// c. Which modules are offered by the Institute for Computer Science (Shortcut 'IFI')?
MATCH (m:Module)<-[:OFFERS]-(ou:OrganizationalUnit {sortCut: "IfI"})
RETURN m

// d. Which module groups import the EWADIS module?
MATCH (mg:ModuleGroup)-[:IMPORTS]->(m:Module{name: "Engineering Web and Data-intensive Systems"})
RETURN mg

// e. Module Imports: Report for each module how often it is imported. The result shall be the module ID, the name, and the number of imports. Sort the result by number of imports in descending order. Return at most 25 results.
MATCH (m:Module)<-[i:IMPORTS]-(:ModuleGroup)
RETURN m.moduleID, m.name, COUNT(i)
ORDER BY COUNT(i)

// f. Statistics I: Determine for each node type (label) how many nodes exist in the graph. Sort the results by label. (assuming that each node has exactly one label)
MATCH (n)
RETURN head(labels(n)) as label, COUNT(n) as count
ORDER BY label

// f. Statistics II: no assumptions, fetching all labels from the database
MATCH (n)
RETURN labels(n) as label, COUNT(n) as count
ORDER BY label

// g. Credit Points: Compute the maximum, minimum, and average of the credit points of all modules.
MATCH(m:Module)
RETURN max(m.creditPoints),
       min(m.creditPoints),
       avg(m.creditPoints)


// h. Module groups with import count: Report for each module how often it is imported. The result shall be the module ID, the name, and the number of imports. Sort the result by number of imports in descending order. Return at most 25 results.
MATCH (m:Module)<-[i:IMPORTS]-(mg:ModuleGroup)
RETURN m.moduleID, m.name, COUNT(i)
ORDER BY COUNT(i) DESC

// i. Module imports: Which is the most often imported module, and how often is it imported? Return the module ID, name, and number of imports.
MATCH (m:Module)<-[i:IMPORTS]-(mg:ModuleGroup)
RETURN m.moduleID, m.name, COUNT(i)
ORDER BY COUNT(i) DESC
LIMIT 1

// j. Big module groups:  Which module groups import compulsory modules with in total more than 18 crdit points? The result shall contain the name of the module group and the total of the compulsory credit points.
MATCH (mg:ModuleGroup)-[:IMPORTS {elective:false}]->(m:Module)
WITH mg.name AS mgName, SUM(m.creditPoints) AS sumCP
WHERE sumCP>18
RETURN mgName, sumCP
ORDER BY sumCP DESC

// k. Persons without Entries: Which persons (lastname, firstname, and email) don’t own a module manual entry?
MATCH (p:Person)
WHERE NOT (p)-[:OWNS]->()
RETURN p.lastName, p.firstName, p.email

// l. All modules of a program of study: Which modules are part of the program with shortcut ’BSc Inf 2019’? Return module ID and name.
MATCH (pos:ProgramOfStudy {shortcut:"BSc Inf 2019"})
      -[:CONTAINS*1..]->(mg:ModuleGroup)
      -[:IMPORTS]->(m:Module)
RETURN m.moduleID,m.name

// m. Recommend modules to extend a program: Determine a list of modules that are part of the master’s program in Web Science (shortcut ’MSc WebSci 2017’) that are not yet part of the Computational Visualistics program (shortcut ’MSc CV 2019’). Return module ID and name.
MATCH (m:Module)<-[:IMPORTS]-(:ModuleGroup)<-[:CONTAINS*1..]-(pos:ProgramOfStudy{shortcut:"MSc WebSci 2017"})
WHERE NOT (m)<-[:IMPORTS]-(:ModuleGroup)<-[:CONTAINS*1..]-(pos:ProgramOfStudy{shortcut:"MSc CV 2019"})
RETURN m
