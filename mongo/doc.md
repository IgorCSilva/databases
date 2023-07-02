
# Mongo

A força do MongoDB está em sua versatilidade,
potência, facilidade de uso e capacidade de lidar com trabalhos grandes e pequenos.

Publicado pela primeira vez em 2009, se tornou rapidapente um dos bancos de dados NoSQL mais utilizados. Uns dos seus principais objetivos centrais é o fácil acesso aos dados e performance. É um banco de dados orientado a documentos, o que possibilita armazenar objetos aninhados. Não é necessário a definição da estrutura dos dados (schemas), similar ao HBase e diferente do Postegres.

Bancos de dados relacionais, como o PostgreSQL, assume que você sabe quais dados serão armazenados, sem necessariamente saber como se quer usar, importando de fato como os dados são armazenados.




- Ao entrar no container do mongo, executar o comando abaixo para entrar no mongo:
`mongosh`

- Caso seja necessário realizar autenticação para executar algumas operações:
`db.auth(<usename>, <password>)`

- Criar um novo banco de dados:
`use <db-name>` (ex.: `use book`)

- Inserindo um registro:
A collection towns é criada, caso não exista.
O banco de dados não existe realmente até que um registro seja inserido.
```js
db.towns.insertOne({
  name: "New York",
  population: 22200000,
  lastCensus: ISODate("2016-07-01"),
  famousFor: [ "the MOMA", "food", "Derek Jeter" ],
  mayor : {
    name : "Bill de Blasio",
    party : "D"
  }
})
```

- Listando as collections:
`show collections`

- Listando os registros da collection:
`db.towns.find()`

Diferente de um banco de dados relacional, Mongo não suporta joins.

- Os registros possuem um campo _id do tipo ObjectId. O id possui sempre 12 bytes, contendo o timestamp, id da máquina, id do processo e 3 bytes de incremento. Essa forma de definir o id, faz com que o Mongo tenha uma natureza distribuída.

- A linguagem natural do Mongo é o JavaScript.

`typeof db` -> object
`typeof db.towns` -> object
`typeof db.towns.insertOne` -> function

- Inspecionando uma função:
`db.towns.insertOne`

- Podemos criar uma função em JavaScript como em `src/insertCity.js`, copiar e colar no terminal. Feito isso, podemos chamar a função para inserir registros no Mongo.

- Podemos utilizar ferramentas para visualizar a estrutura do mongo, seus dados e até editá-los pela interface. Uma dessas ferramentas é o Robo 3T, antes conhecido como Robomongo.

## Realizando leituras no Mongo

- Acessando todos os registros:
`db.<collection-name>.find()` (ex.: `db.towns.find()`)

- Para acessar um registro específico:
`db.<collection-name>.find({ _id: <id>})` (ex.: `db.towns.find({ _id: ObjectId("63e2dca13e9cce31b90c42f5")})`)

- Se quisermos trazer apenas alguns campos, podemos especificar quais são da seguinte maneira (no lugar do true podemos colocar 1):
`db.towns.find({ _id: ObjectId("63e2dca13e9cce31b90c42f5")}, {name: true})`

- Se quisermos trazer os registros sem alguns campos, podemos especificar quais são da seguinte maneira (no lugar do false podemos colocar 0 ou null):
`db.towns.find({ _id: ObjectId("63e2dca13e9cce31b90c42f5")}, {name: false})`

### Realizando consultas com filtros
- Buscando registros com nome que começa com P e possuem população menor que 10.000:
```js
db.towns.find(
  {name: /^P/, population: {$lt: 10000}},
  {_id: 0, name: 1, population: 1}
)
```

Os operadores condicionais no Mongo seguem o formato {$op: value}, onde $op é a operação que se quer utilizar.

- Utilizando range de valores:
```js
var population_range = {
  $lt: 1000000,
  $gt: 10000
}

db.towns.find(
  {name: /^P/, population: population},
  {name: true}
)
```

- Utilizando filtro por datas:
```js
db.towns.find(
  {lastCensus: {$gte: ISODate("2016-06-01")}},
  {_id: false, name: true}
)
```

- Realizando buscas através de valores em arrays:
```js
db.towns.find(
  {famousFor: 'food'},
  {_id: false, name: true, famousFor: true}
)
```

- Realizando buscas através de valores em arrays com valores parciais:
```js
db.towns.find(
  {famousFor: /MOMA/},
  {_id: false, name: true, famousFor: true}
)
```

- Buscando através de mais de um valor em listas:
```js
db.towns.find(
  {famousFor: {$all: ['food', 'beer']}},
  {_id: false, name: true, famousFor: true}
)
```

- Buscando registros em que não há valores em listas:
```js
db.towns.find(
  {famousFor: {$nin: ['food', 'beer']}},
  {_id: false, name: true, famousFor: true}
)
```

Mesmo podendo fazer essas buscas, o verdadeiro poder do Mongo está na habilidade de realizar consultas estabelecendo critérios em campos de dados aninhados. Para realizar consultas em documentos aninhados, separamos o nome do campo por um ponto.

- Busca usando documentos aninhados:
```js
db.towns.find(
  {'mayor.party': 'D'},
  {_id: false, name: true, mayor: true}
)
```

- Buscando aqueles que não possuem determinada informação:
```js
db.towns.find(
  {'mayor.party': {$exists: false}},
  {_id: false, name: true, mayor: true}
)
```

## Realizando buscas utilizando mais de um campo como critério
Para isso, usamos a diretiva elemMatch.

- Saber quantidade de documentos:
`db.countries.countDocuments()`

- Buscando os países que exportam bacon OU exportam algo saboroso:
```js
db.countries.find(
  {'exports.foods.name': 'bacon', 'exports.foods.tasty': true},
  {_id: false, name: true}
)
```

- Buscando os países que satisfazem todos os critérios:
```js
db.countries.find(
  {
    'exports.foods': {
      $elemMatch: {
        name: 'bacon',
        tasty: true
      }
    }
  },
  {_id: false, name: true}
)
```

- Usando $elemMatch com operadores:
```js
db.countries.find(
  {
    'exports.foods': {
      $elemMatch: {
        tasty: true,
        condiment: {$exists: true}
      }
    }
  },
  {_id: false, name: true}
)
```

## Operadores booleanos

- Buscando por id ou por nome:
```js
db.countries.find(
  {
    $or: [
      {_id: 'mx'},
      {name: 'United States'}
    ]
  },
  {_id: true, name: true}
)
```

### Outros operadores

| Command | Description |
|\$regex | Match by any PCRE-compliant regular expression string (or just use the // delimiters as shown earlier)|
|\$ne | Not equal to|
|\$lt | Less than|
|\$lte | Less than or equal to|
|\$gt | Greater than|
|\$gte | Greater than or equal to|
|\$exists | Check for the existence of a field|
|\$all | Match all elements in an array|
|\$in | Match any elements in an array|
|\$nin | Does not match any elements in an array|
|\$elemMatch | Match all fields in an array of nested documents|
|\$or | or|
|\$nor | Not or|
|\$size | Match array of given size|
|\$mod | Modulus|
|\$type | Match if field is a given datatype|
|\$not | Negate the given operator check|


# Updating

Funções similares: updateMany e bulkWrite.
O update requer dois parâmetros: updateOne(criteria, operation)
* criteria: seleciona o elemento a ser alterado.
* operation: um objeto cujos parâmetros vão sobrescrever os do documento selecionado ou um operador de modificação.

- Alterando todo o documento para OR:
```js
db.towns.updateOne(
  {_id: ObjectId("4d0ada87bb30773266f39fe5")},
  {state: 'OR'}
)
```

- Alterando um estado para OR:
```js
db.towns.updateOne(
  {_id: ObjectId("4d0ada87bb30773266f39fe5")},
  {$set: {state: 'OR'}}
)
```

- Incrementando valor de um campo:
```js
db.towns.updateOne(
  {_id: ObjectId("4d0ada87bb30773266f39fe5")},
  {$inc: {population: 1000}}
)
```

### Algumas outras diretivas

|Command | Description |
|$set | Sets the given field with the given value|
|$unset | Removes the field|
|$inc | Adds the given field by the given number|
|$pop | Removes the last (or first) element from an array|
|$push | Adds the value to an array|
|$pushAll | Adds all values to an array|
|$addToSet | Similar to push, but won’t duplicate values|
|$pull | Removes matching values from an array|
|$pullAll | Removes all matching values from an array|

## References
Como o Mongo não foi construído para realização de joins, esta operação é ineficiente nele. Mesmo assim, as vezes se torna necessário um documento referenciar outro. A comunidade do Mongo sugere usar um contrutor como `{$ref: "collection_name", $id: "reference_id"}`.

**Obs.:** Não está funcionando com $ref. Os exemplos a seguir vão ter os $ removidos por isso.

- Fazendo com que um registro em towns tenha referência em countries:
```js
db.towns.updateOne(
  {_id: ObjectId('63e2dd193e9cce31b90c42f6')},
  {$set: {country: {ref: 'countries', id: 'us'}}}
)
```

- Buscando documento pela referência:
```js
var portland = db.towns.findOne({ _id: ObjectId("63e2dd193e9cce31b90c42f6") })

db.countries.findOne({_id: portland.country.id})
```

- Buscando documento pela referência de outra forma:
```js
var portland = db.towns.findOne({ _id: ObjectId("63e2dd193e9cce31b90c42f6") })

db[portland.country.ref].findOne({_id: portland.country.id})
```

## Deleting

Funções similares: deleteOne, deleteMany, findOneAndDelete e bulkWrite.

- Removendo registros:
```js
var badBacon = {
  'exports.foods': {
    $elemMatch: {
      name: 'bacon',
      tasty: false
    }
  }
}

db.countries.find(badBacon)
db.countries.deleteOne(badBacon)
db.countries.countDocuments()
```

## Reading with code

Podemos utilizar código para realizar as operações, no entanto isso é feito de forma mais lenta. Um cuidado que também temos que ter é que o código javascript pode não ser executado corretamente pela inexistência do campo que se quer acessar.

- Consulta usando código:
```js
db.towns.find({
  $where: "this.population > 6000 && this.population < 600000"
})

db.towns.find({
  $where: "this.population > 6000 && this.population < 600000",
  famousFor: /Phil/
})
```


# Indexing, Aggregating and Mapreduce

Mongo possui uma boa organização dos seus dados usando, por exemplo, árvore B, 2D e GeoSpatial indexes.

- Gerando 100.000 números de telefone, entre 1-800-555-00000 e 1-800-565-0000.
```js
const populatePhones = function(area, start, stop) {
  for(var i = start; i < stop; i++) {
    var country = 1 + ((Math.random() * 8) << 0);
    var num = (country * 1e10) + (area * 1e7) + i;
    var fullNumber = "+" + country + " " + area + "-" + i;
    
    db.phones.insert({
      _id: num,
      components: {
        country: country,
        area: area,
        prefix: (i * 1e-4) << 0,
        number: i
      },
      display: fullNumber
    });
    print("Inserted number " + fullNumber);
  }
  print("Done!");
}
```
- Inserindo e consultando uma quantidade específica de números:
```js
populatePhones(800, 5550000, 5650000)

db.phones.find().limit(2)
```

Quando uma nova collection é criada, o Mongo automaticamente cria um index pelo _id.

- Mostrando todos os índices do banco de dados:
```js
db.getCollectionNames().forEach(function(collection) {
  print("Indexes for the " + collection + " collection:")
  printjson(db[collection].getIndexes())
})

// Resultado:

// Indexes for the phones collection:
// [ { v: 2, key: { _id: 1 }, name: '_id_' } ]
// Indexes for the countries collection:
// [ { v: 2, key: { _id: 1 }, name: '_id_' } ]
// Indexes for the towns collection:
// [ { v: 2, key: { _id: 1 }, name: '_id_' } ]
```

- Checando query sem a otimização da criação de um index (verificar valor de executionTimeMillisEstimate, milissegundos para completar a consulta):
```js
db.phones.find({display: "+1 800-5650001"}).
  explain("executionStats").executionStats

// Resultado:

// {
//   executionSuccess: true,
//   nReturned: 0,
//   executionTimeMillis: 270,
//   totalKeysExamined: 0,
//   totalDocsExamined: 100000,
//   executionStages: {
//     stage: 'COLLSCAN',
//     filter: { display: { '$eq': '+1 800-5650001' } },
//     nReturned: 0,
//     executionTimeMillisEstimate: 57,
//     works: 100002,
//     advanced: 0,
//     needTime: 100001,
//     needYield: 0,
//     saveState: 100,
//     restoreState: 100,
//     isEOF: 1,
//     direction: 'forward',
//     docsExamined: 100000
//   }
// }
```

- Criando um index com o campo display e que não aceita valores duplicados:
```js
db.phones.ensureIndex(
  {display: 1},
  {unique: true, dropDups: true}
)
```

Agora, ao verificar os dados de estatística novamente, vemos que o tempo de busca diminuiu drasticamente:
```js
{
  executionSuccess: true,
  nReturned: 0,
  executionTimeMillis: 3,
  totalKeysExamined: 0,
  totalDocsExamined: 0,
  executionStages: {
    stage: 'FETCH',
    nReturned: 0,
    executionTimeMillisEstimate: 2,
    works: 1,
    advanced: 0,
    needTime: 0,
    needYield: 0,
    saveState: 0,
    restoreState: 0,
    isEOF: 1,
    docsExamined: 0,
    alreadyHasObj: 0,
    inputStage: {
      stage: 'IXSCAN',
      nReturned: 0,
      executionTimeMillisEstimate: 2,
      works: 1,
      advanced: 0,
      needTime: 0,
      needYield: 0,
      saveState: 0,
      restoreState: 0,
      isEOF: 1,
      keyPattern: { display: 1 },
      indexName: 'display_1',
      isMultiKey: false,
      multiKeyPaths: { display: [] },
      isUnique: true,
      isSparse: false,
      isPartial: false,
      indexVersion: 2,
      direction: 'forward',
      indexBounds: { display: [ '["+1 800-5650001", "+1 800-5650001"]' ] },
      keysExamined: 0,
      seeks: 1,
      dupsTested: 0,
      dupsDropped: 0
    }
  }
}
```

Realizando profiling.
- Estudar como fazer profiling.

Em produção devemos sempre construir os índices em background, usando a opção { background: 1 }.

- Construindo index com campo aninhado:
```js
db.phones.ensureIndex({ "components.area": 1 }, { background: 1 })
```

- Listando todos os índices da collection phones:
```js
db.phones.getIndexes()
```

Criar índices em uma coleção muito grande pode ser custoso e consumir recursos de forma significativa. O maior custo dos índices no Mongo (maior do que em bancos relacionais) vem de sua natureza por não usar schemas.

## Comandos interessantes do mongo para se explorar

|Command | Description|
|mongodump Exports data from Mongo into .bson files. That can mean entire collections
or databases, filtered results based on a supplied query, and more.

mongofiles Manipulates large GridFS data files (GridFS is a specification for BSON
files exceeding 16 MB).

mongooplog Polls operation logs from MongoDB replication operations.

mongorestore Restores MongoDB databases and collections from backups created
using mongodump .

mongostat
Displays basic MongoDB server stats.

mongoexport Exports data from Mongo into CSV (comma-separated value) and JSON
files. As with mongodump , that can mean entire databases and collections
or just some data chosen on the basis of query parameters.

mongoimport Imports data into Mongo from JSON, CSV, or TSV (term-separated value)
files. We’ll use this tool on Day 3.

mongoperf Performs user-defined performance tests against a MongoDB server.

mongos Short for “MongoDB shard,” this tool provides a service for properly
routing data into a sharded MongoDB cluster (which we will not cover
in this chapter).

mongotop Displays usage stats for each collection stored in a Mongo database.

bsondump Converts BSON files into other formats, such as JSON.

For more in-depth info, see the MongoDB reference documentation. a
a.
https://docs.mongodb.com/manual/reference/program


## Aggregated Queries

count() é um agregador que retornar a quantidade que satisfez algum filtro.

- Utilizando o count():
```js
db.phones.countDocuments({'components.number': {$gt: 5599999}})
```

O agregador distinct() retornar todos os valores que satisfazem a condição fornecida, mas não o documento inteiro:
```js
db.phones.distinct('components.number', {'components.number': {$lt: 5550005}})
```

O agregador aggregate() nos habilita a criar uma lógica de pipeline que possui estágios como:
* $match: filtros que retornam um conjunto de documentos;
* $group: funções que agrupam por algum atributo;
* $sort(): lógica que ordena os documentos por uma chave;
* e outros...
(https://docs.mongodb.com/manual/reference/operator/aggregation-pipeline/)

Podemos pensar no aggregate como uma combinação de WHERE, GROUP BY e ORDER BY em SQL.


- Carregando um arquivo com comandos do Mongo:
```js
load('src/mongoCities100000.js')
db.cities.count()
```

- Encontrando a média da população para todas as cidades na timezone Europe/Andorra:
```js
db.cities.aggregate([
  {
    $match: {
      timezone: {
        $eq: 'Europe/Andorra'
      }
    }
  },
  {
    $group: {
      _id: 'averagePopulation',
      avgPop: {
        $avg: '$population'
      }
    }
  }
])

// Resultado

// [ { _id: 'averagePopulation', avgPop: 8097.666666666667 } ]
```

- Pegando todos os documentos com timezone Europe/Andorra, ordenar de forma decrescente por população, e projetar os documentos que contém o campo population:
```js
db.cities.aggregate([
  {
    $match: {
      timezone: {
        $eq: 'Europe/Andorra'
      }
    }
  },
  {
    $sort: {
      population: -1
    }
  },
  {
    $project: {
      _id: 0,
      name: 1,
      population: 1
    }
  }
])

// Resultado

// [
//   { name: 'Andorra la Vella', population: 20430 },
//   { name: 'les Escaldes', population: 15853 },
//   { name: 'Encamp', population: 11223 },
//   { name: 'Sant Julià de Lòria', population: 8022 },
//   { name: 'la Massana', population: 7211 },
//   { name: 'Canillo', population: 3292 },
//   { name: 'Ordino', population: 3066 },
//   { name: 'Pas de la Casa', population: 2363 },
//   { name: 'Arinsal', population: 1419 }
// ]
```

- Deletando uma collection:
```js
db.cities.drop()
```

## Server-Side Commands

- Mostrando detalhes de acesso de todas as collections:
```js
use admin
db.runCommand('top')

// Resultado

// {
//   totals: {
//     note: 'all times in microseconds',
//     'admin.system.users': {
//       total: { time: 2280, count: 2 },
//       readLock: { time: 2280, count: 2 },
//       writeLock: { time: 0, count: 0 },
//       queries: { time: 0, count: 0 },
//       getmore: { time: 0, count: 0 },
//       insert: { time: 0, count: 0 },
//       update: { time: 0, count: 0 },
//       remove: { time: 0, count: 0 },
//       commands: { time: 0, count: 0 }
//     },
//     'admin.system.version': {
//       total: { time: 460, count: 1 },
//       readLock: { time: 460, count: 1 },
//       writeLock: { time: 0, count: 0 },
//       queries: { time: 0, count: 0 },
//       getmore: { time: 0, count: 0 },
//       insert: { time: 0, count: 0 },
//       update: { time: 0, count: 0 },
//       remove: { time: 0, count: 0 },
//       commands: { time: 0, count: 0 }
//     },
//     'config.system.sessions': {
//       total: { time: 188, count: 2 },
//       readLock: { time: 188, count: 2 },
//       writeLock: { time: 0, count: 0 },
//       queries: { time: 0, count: 0 },
//       getmore: { time: 0, count: 0 },
//       insert: { time: 0, count: 0 },
//       update: { time: 0, count: 0 },
//       remove: { time: 0, count: 0 },
//       commands: { time: 188, count: 2 }
//     },
//     'config.transactions': {
//       total: { time: 679, count: 1 },
//       readLock: { time: 679, count: 1 },
//       writeLock: { time: 0, count: 0 },
//       queries: { time: 679, count: 1 },
//       getmore: { time: 0, count: 0 },
//       insert: { time: 0, count: 0 },
//       update: { time: 0, count: 0 },
//       remove: { time: 0, count: 0 },
//       commands: { time: 0, count: 0 }
//     },
//     'local.system.replset': {
//       total: { time: 2, count: 1 },
//       readLock: { time: 2, count: 1 },
//       writeLock: { time: 0, count: 0 },
//       queries: { time: 0, count: 0 },
//       getmore: { time: 0, count: 0 },
//       insert: { time: 0, count: 0 },
//       update: { time: 0, count: 0 },
//       remove: { time: 0, count: 0 },
//       commands: { time: 0, count: 0 }
//     }
//   },
//   ok: 1
// }
```

- Listando todos os comandos disponíveis para aquele banco de dados:
```js
use book
db.listCommands()
```

Inserindo função no mongo, para se chamada quando executarmos a função getLast:
```js
db.system.js.insertOne(
  {
    _id: 'getLast',
    value: function(collection) {
      return collection.find({}).sort({'_id': 1}).limit(1)
    }
  }
)
```

# MapReduce
As operações de mapreduce são desenvolvidas para computar quantidades grandes de dados. Cada operação mapreduce é dividida em dois passos. Primeiro, o passo map tem uma série de operações de filtros e/ou ordenação, fazendo com que o grupo maior de dados se resuma a um subconjunto. Segundo, o passo reduce executa alguns tipos de operações no subconjunto resultante.

Para gerar um relatório que conta todos o números que contém os mesmos dígitos para cada país, fazemos o seguinte:

```js
load('app/src/distinctDigits.js')
load('app/src/map1.js')
load('app/src/reduce1.js')

results = db.runCommand({
  mapReduce: 'phones',
  map: map,
  reduce: reduce,
  out: 'phones.report'
})

db.phones.report.find({'_id.country' : 8})
```
Notemos que as keys emitidas estão no campo _id, e os dados retornados pelos reducers estão no campo value.



# Replica Sets

Nós não devemos executar apenas uma instância do Mongo em produção e sim múltiplas instâncias, replicando os dados entre elas.


- Executar o docker-compose com o arquivo de replica set:
`docker-compose -f docker-compose-rs.yaml up --build`

- Entrar em algum container:
`docker exec -it sdsw_mongo_rs3_1_database bash`

`mongosh`
`use admin`

- Configurar os hosts(copiar e colar o código abaixo):
```js
rs.initiate({
  _id: 'book',
  members: [
    {_id: 1, host: 'mongo_rs3_1'},
    {_id: 2, host: 'mongo_rs3_2'},
    {_id: 3, host: 'mongo_rs3_3'}
  ]
})
```

- Verificar status do replica set:
`rs.status().ok`
(resultado tem que ser 1)

Após isso ficamos com um node primário e dois secundários.
Podemos verificar executando:
`rs.status()`

O primário será o server master. Se não estivermos no container do master, deveremos ir para ele.

- Realizando teste no console do master:
`db.echo.insertOne({say: 'HELLO!'})`

Se matermos o container do master e entrarmos em outro container, ao verificar o status notaremos que outra instância foi colocada como primária. Se executarmos o comando de busca, encontraremos os dados que o master inseriu:

`db.echo.find()`
(deve mostrar os dados de HELLO!)

- Entrar em um container de instância secundária.
Para verificar se a instância é secundária mesmo, podemos também executar o seguinte comando:
`db.isMaster().ismaster`
(para instância primária retorna true, para secundária retorna false)

Verificando qual host da instância primária:
`db.isMaster().primary`

Tentando inserir algum dado na instância secundária:
`db.echo.insertOne({say: 'is this thing on?'})`
(resultado esperado: MongoServerError: not primary)

Só há um master por replica set no mongo(diferente do CouchDB, que trabalha com multi masters), e é com ele que devemos intragir.
De acordo com os mecanismos de eleição de um novo master quando o atual morre, é preferível ter um número ímpar de nós em um replica set.


# Sharding

Um dos objetivos principais do Mongo é entregar uma grande quantidade de dados de forma segura e rápida. Uma forma de se fazer isso, é distribuindo ranges de datas de forma horizontal(entre as instâncias).

- Executar o docker-compose do sharding:
`docker-compose -f docker-compose-sh.yaml up`

- Verificar se todos os containers estão de pé:
`docker-compose -f docker-compose-sh.yaml ps`

- Configurando o replica set do shard 1:
Para isso precisamos entrar em seu container, ir para o banco de dados admin, copiar e colar o código abaixo:
```js
rs.initiate({
  _id: 'mongo_sh_rs_1',
  members: [
    {_id: 1, host: 'mongo_sh_1:27017'}
  ]
})
// { ok: 1 }
```

- Configurando o replica set do shard 2:
Para isso precisamos entrar em seu container, ir para o banco de dados admin, copiar e colar o código abaixo:
```js
rs.initiate({
  _id: 'mongo_sh_rs_2',
  members: [
    {_id: 1, host: 'mongo_sh_2:27017'}
  ]
})
// { ok: 1 }
```

Precisamos criar um servidor onde ficam nossas configurações. Se estamos ordenando uma lista de nomes em ordem alfabética, o Mongo precisa saber que os registros de A até K devem ficar em uma instância e L até Z em outra. Para isso que temos o serviço de configuração.

- Entrar no container de configuração e executar os seguintes passos:
`mongosh`
`use admin`

Copiar e colar o código abaixo:
```js
rs.initiate({
  _id: 'configSet',
  configsvr: true,
  members: [
    {
      _id: 0,
      host: 'mongo_sh_rs_config'
    }
  ]
})
```

Devemos receber uma resposta de sucesso, como {ok: 1}.

Verificando status do replica set:
`rs.status().ok`
(resultado: 1)


Por fim, precisamos do mongos, que é o ponto único de entrada dos clientes. mongos é uma versão leve do servidor mongod. Quase todos os comandos de mongod podem ser executados no mongos, o que faz com que ele se torne um bom meio de campo para que os clientes se comuniquem com múltiplos servidores que utilizam o mecanismo de sharding.

Teremos:
clients se comunicando com mongos
mongos com config, shard1 e shard2
config com mongos, shard1 e shard2

- Configurando os fragmentos(shardings):
Entrar no container do mongos e realizar os passos a seguir:
Ir para o banco de dados admin
`use admin`

Configurar o primeiro fragmento:
```js
sh.addShard('mongo_sh_rs_1/mongo_sh_1:27017')
// {ok: 1}
```

Configurar o segundo fragmento:
```js
sh.addShard('mongo_sh_rs_2/mongo_sh_2:27017')
// {ok: 1}
```

Com isso feito, precisamos especificar o banco de dados e a collection a ser fragmentada.

```js
db.runCommand({ enablesharding : "test" })
// { ok: 1 }

db.runCommand({ shardcollection : "test.cities", key : {name : 1} })
// { ok: 1 }
```

Importando arquivo com 100000 inserções(dentro do container e fora do terminal do mongo):

`
mongoimport \
--db test \
--collection cities \
--type json \
app/src/mongoCities100000.json
`

Resultado:
2023-03-04T12:24:59.703+0000    connected to: mongodb://localhost/
2023-03-04T12:25:02.704+0000    [###################.....] test.cities  10.9MB/13.7MB (79.8%)
2023-03-04T12:25:05.443+0000    [########################] test.cities  13.7MB/13.7MB (100.0%)
2023-03-04T12:25:05.443+0000    99838 document(s) imported successfully. 0 document(s) failed to import.

Podemos notar que nem todos os registros foram inseridos.


# GeoSpatial Queries
GeoSpatial queries busca dados que estão próximos de um determinado valor.

- Ir para banco de dados onde as cidades foram inseridas(test):
`use test`

- Setando index 2d:
```js
db.cities.ensureIndex({ location : "2d" })
// [ 'location_2d' ]
```

- Usando pipeline aggregation para buscar uma lista de todas as cidades próximas a Portland ou ordenar de forma decrescente a população, mostrando também a distância de todas elas para o ponto 45.52/-122.67 (latitude/longitude).

```js
db.cities.aggregate([
  {
    $geoNear: {
      near: [45.52, -122.67],
      distanceField: 'dist'
    }
  },
  {
    $sort: {
      population: -1
    }
  },
  {
    $project: {
      _id: 0,
      name: 1,
      population: 1,
      dist: 1
    }
  }
])

// [
//   { name: 'Shanghai', population: 14608512, dist: 244.54638863064818 },
//   {
//     name: 'Buenos Aires',
//     population: 13076300,
//     dist: 102.736955391891
//   },
//   { name: 'Mumbai', population: 12691836, dist: 197.30638905796158 },
//   { name: 'Mexico City', population: 12294193, dist: 35.1427049388134 },
//   { name: 'Karachi', population: 11624219, dist: 190.86867446545546 },
//   { name: 'İstanbul', population: 11174257, dist: 151.68660710972873 },
//   { name: 'Delhi', population: 10927986, dist: 200.59590119386235 },
//   { name: 'Manila', population: 10444527, dist: 245.60574352909583 },
//   { name: 'Moscow', population: 10381222, dist: 160.61182730621678 },
//   ...
// ]
```

# GridFS
Para tratar duplicação de arquivos entre os servidores, o Mongo utiliza o GridFS.

- Listando arquivos dentro do mongos:
`mongofiles list`
(inicialmente a lista está vazia)

- Inserindo arquivo:
`echo "here's some file data" > just-some-data.txt`
`mongofiles put just-some-data.txt`

Resultado:
2023-03-04T12:53:09.546+0000  connected to: mongodb://localhost/
2023-03-04T12:53:09.546+0000  adding gridFile: just-some-data.txt

2023-03-04T12:53:09.605+0000  added gridFile: just-some-data.txt


Ao listar os arquivos novamente, vemos que o que acabamos de inserir é exibido.

Entrando no terminal do mongo, listar as collections:
`show collections`

Notamos que há a collection fs.files, que é onde nossos arquivos ficam.

Podemos saber informações dos arquivos com o seguinte comando:
```js
db.fs.files.find()
```

Talvez o Mongo seja uma resposta muito mais natural do que  bancos de dados relacionais em muitos casos que a aplicação é construída guiada pelo conjunto de dados a se trablhar.


# Schema Validations

Criando uma collection com validações:
```js
db.createCollection("students", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         title: "Student Object Validation",
         required: [ "address", "major", "name", "year" ],
         properties: {
            name: {
               bsonType: "string",
               description: "'name' must be a string and is required"
            },
            year: {
               bsonType: "int",
               minimum: 2017,
               maximum: 3017,
               description: "'year' must be an integer in [ 2017, 3017 ] and is required"
            },
            gpa: {
               bsonType: [ "double" ],
               description: "'gpa' must be a double if the field exists"
            }
         }
      }
   }
} )
```

Tentando inserir dados inválidos:
```js
db.students.insertOne( {
   name: "Alice",
   year: Int32( 2019 ),
   major: "History",
   gpa: Int32(3),
   address: {
      city: "NYC",
      street: "33rd Street"
   }
} )
```

A operação acima deve falhar porque o valor de gpa é um inteiro, quando se espera um double.

Tentando inserir dados válidos:
```js
db.students.insertOne( {
   name: "Alice",
   year: Int32( 2019 ),
   major: "History",
   gpa: Double(3.0),
   address: {
      city: "NYC",
      street: "33rd Street"
   }
} )
```

Podemos utilizar expressões nas validações:
```js
db.createCollection( "orders",
  {
    validator: {
      $expr:
        {
            $eq: [
              "$totalWithVAT",
              { $multiply: [ "$total", { $sum:[ 1, "$VAT" ] } ] }
            ]
        }
    }
  }
)
```

Inserindo dados inválidos:
```js
db.orders.insertOne( {
   total: NumberDecimal("141"),
   VAT: NumberDecimal("0.20"),
   totalWithVAT: NumberDecimal("169")
} )
```

Inserindo dados válidos:
```js
db.orders.insertOne( {
   total: NumberDecimal("141"),
   VAT: NumberDecimal("0.20"),
   totalWithVAT: NumberDecimal("169.2")
} )
```