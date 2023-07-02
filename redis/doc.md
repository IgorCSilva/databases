# Redis
Redis é geralmente utilizado para diminuir o gargalo entre as operações do sistema.

Com a primeira release em 2009, o Redis(REmote DIctionary Service) é uma ferramenta que armazena dados no formato chave-valor com um conjunto sofisticado de comandos. Quando se fala de velocidade, Redis é um excelente exemplo. Leituras são rápidas e escritas ainda mais, chegando a 100 mil operações SET por segundo, segundo alguns benchmarks.

## Armazenamento de estruturas de dados

Redis suporta estruturas de dados avançadas, embora não como um banco de dados orientado a documento. Ele suporta operações baseadas em conjunto (em um banco de dados relacional são operações que juntam tabelas diferentes, usando o JOIN para formar o conjunto), mas não com a granularidade ou com os suportes a tipo encontrados em um banco de dados relacional. E ele é rápido, trocando durabilidade por velocidade.

Redis também é utilizado como uma fila, pilha ou um sistema publish-subscribe. Ele possui políticas de expiração configuráveis, níveis de durabilidade e opções de replicação. Isso tudo faz com que o Redis seja mais que um gênero de banco de dados.

## CRUD e Datatypes

Para executar o Redis utilizando o docker, primeiro montamos o arquivo docker-compose com os dados abaixo:

```yaml
version: '3.8'
services:
  redis:
    image: redis:7.0.10-alpine
    container_name: redis_database
    restart: always
    ports:
      - '6379:6379'
    volumes: 
      - redis_data:/data

volumes:
  redis_data:
    driver: local
```

Levantando o container pela primeira vez:
`docker-compose up --build`

Para realizar as operações por linha de comando, precisamos entrar no container.

Entrar no container:
`docker exec -it redis_database sh`

Agora preciamos acessar o terminal do Redis:
`redis-cli`

Testando conexão com o banco:
`PING`

resultado esperado:
PONG

Em casos de dúvida, solicitar os dados de ajuda:
`help`

### Encurtador de URL
Vamos trabalhar com o Redis agora para montar um encurtador de URLs, como o tinyurl.com e o bit.ly.

No Redis, podemos utilizar a operação SET para salvar os dados, utilizando a url encurtada como chave e a url original como valor. O operador SET requer sempre dois parâmetros: a key e o value.

Inserindo dados:
`SET 7wks http://www.sevenweeks.org/`

Lendo os dados pela chave:
`GET 7wks`

Neste momento devemos obter como resposta: "http://www.sevenweeks.org/"


Para inserir múltiplos dados usamos o MSET:
`MSET gog http://www.google.com yah http://www.yahoo.com`

Já para buscar múltiplos dados usamos o MGET:
`MGET gog yah`

resultado:
1) "http://www.google.com"
2) "http://www.yahoo.com"


Redis, além de armazenar inteiros, também realiza algumas operações sobre eles.
Podemos implementar um contador, por exemplo:
`SET count 2`
`INCR count`
`GET count` (resultado deve ser "3")

Mesmo o GET retornando uma string, as operações sobre inteiros reconhecem quando é possível ou não realizar tão operação.

Ao tentar incrementar um dado inválido, obtemos o seguinte:
`SET bad_count "a"`
`INCR bad_count` (resultado: (error) ERR value is not an integer or out of range)

Incrementando especificando um valor diferente de 1:
`INCRBY count 3`

As operações de decremento associadas são DECR e DECRBY.


## Transações
O Redis possui o bloco MULTI que segue o conceito similar de transação dos bancos de dados relacionais e orientado a grafos.

Para montar um bloco MULTI iniciamos com este operador e finalizamos com o operador EXEC:
`MULTI`
`SET prag http://pragprog.com`
`INCR count`
`EXEC`

Resultado passo a passo das operações acima:
127.0.0.1:6379> MULTI
OK
127.0.0.1:6379(TX)> SET prag http://pragprog.com
QUEUED
127.0.0.1:6379(TX)> INCR count
QUEUED
127.0.0.1:6379(TX)> EXEC
1) OK
2) (integer) 7

Buscando dado inserido:
`GET prag` (resultado: "http://pragprog.com")

Agora vamos incrementar um dado inválido dentro de um bloco MULTI:
`MULTI`
`SET prag2 http://pragprog2.com`
`INCR bad_count`
`EXEC`

O valor é setado, mesmo que o incremento tenha falhado. Para desconsiderar o bloco MULTI no meio do caminho utilizamos o operador DISCARD:
`MULTI`
`SET prag3 http://pragprog3.com`
`INCR bad_count`
`DISCARD`
`EXEC`

O Redis não possui os mecanismos de rollback. A transação no Redis deve ser encarada como um bloco de operações que serão realizadas de uma vez (atomicamente) não como um gerenciamento de estados do banco de dados.


## Estruturas de dados complexos
As estruturas de dados no Redis podem ter mais de 4 bilhões de valores por chave.
Os comandos do Redis seguem um padrão, em que geralmente os comandos de SET iniciam com S, os de hashes com H e os de ordenação com Z. Comandos de listas geralmente começão com L(left) ou R(right), como LPUSH.

### Hashes
Hashes podem ser vistos como objetos aninhados que podem ter qualquer número de pares chave-valor.

Inserindo dados com chaves separadas:
`MSET user:luc:name "Luc" user:luc:password s3cret`

Buscando os dados inseridos:
`MGET user:luc:name user:luc:password`

Ao se utilizar hashes, podemos fazer com que uma chave tenha seus próprios pares de chave-valor:
`HMSET user:luc name "Luc" password s3cret`

Para buscar todos os valores das chaves de um hash, executamos o seguinte:
`HVALS user:luc` (obtendo o mesmo resultado do MGET acima)

Já para buscar as chaves usamos:
`HKEYS user:luc`

Buscando o valor de uma chave específica:
`HGET user:luc name`


Diferente de bancos de dados orientados a documento, Redis não dá suporte a hashes aninhados (os hashes também não aceitam outros dados complexos, como listas). Hashes podem apenas armazenar strings, não outros hashes ou conjuntos de dados.

Hashes possuem operações para deletar campos (HDEL), incrementar um valor inteiro (HINCRBY), saber a quantidade de campos (HLEN), buscar todas as chaves e valores (HGETALL), definir um valor só se a chave não existir (HSETNX) entre outros.

### Listas
As listas também podem ser utilizadas para criarmos filas e pilhas.

Criando uma lista:
`RPUSH eric:wishlist 7wks gog prag`
(integer) 3

Consultando o tamanho da lista:
`LLEN eric:wishlist`

Buscando um range de valores de uma lista:
`LRANGE eric:wishlist 0 -1`

Removendo valores da lista que dão match:
`LREM eric:wishlist 0 gog` 

0 indica que devemos remover todos que dão match, para um número diferente de 0 é removido apenas aquela quantidade.

Se o valor for negativo, realizamos a busca do final para o começo da lista.

Para remover e pegar os dados do começo da lista usamos o LPOP:
`LPOP eric:wishlist` 

Após RPUSH, se quisermos o comportamento de uma fila usamos LPOP, se quisermos o comportamento de uma pilha usamos RPOP. Similarmente podemos usar o LPUSH com RPOP e LPOP.


Para remover dados de uma lista e inserir em outra de forma atômica, fazemos o seguinte:
`RPOPLPUSH eric:wishlist eric:visited`

INCRIVELMENTE NÃO EXISTEM OS COMANDOS LPOPLPUSH, RPOPRPUSH E LPOPRPUSH.


### Bloqueando listas
Abir outro terminal para aguardar a publicação de uma mensagem ou parar de aguardar após 5 minutos:

no segundo terminão executar:
`BRPOP comments 300` (neste momento o terminal ficará bloqueado)

no primeiro terminal executar:
`LPUSH comments "Prag is a great publisher!"`

No segundo terminal veremos:
1) "comments"
2) "Prag is a gerate publisher!"
(34.94s)

e o terminal será desbloqueado.

Se formos listar os elementos da lista comments, veremos que ela está vazia. BRPOP bloqueia o terminal e quando a mensagem é inserida na lista comments ele remove (POP) pela direita (R) o valor. Também temos BLPOP e BRPOPLPUSH.


### Sets
Sets são conjuntos de dados que não têm uma ordenação específica e que não possuem dados duplicados. São boas estruturas de dados para realizarmos operações de união e intersecção.

Podemos adicionar um conjunto de dados usando o comando SADD:
`SADD news nytimes.com pragprog.com`

Podemos coletar os dados de um set da seguinte maneira:
`SMEMBERS news`

Agora criamos o seguinte set:
`SADD tech pragprog.com apple.com`

Para encontrar a intersecção dos dois sets criados, usamos o SINTER:
`SINTER news tech`
1) "pragprog.com"

Para listar todos os itens que estão em um set mas não estão em outro, usamos o SDIFF:
`SDIFF news tech`
1) "nytimes.com"

Já para encontrarmos a união dos dados, usamos SUNION (por serem sets, as duplicações são removidas):
`SUNION news tech`
1) "apple.com"
2) "nytimes.com"
3) "pragprog.com"

Podemos também salvar a união de vários sets em um novo set:
`SUNIONSTORE websites news tech`
`SMEMBERS websites`
1) "apple.com"
2) "nytimes.com"
3) "pragprog.com"

Desta forma podemos também criar uma cópia de um set:
`SUNIONSTORE news_copy news`

Comandos semelhantes existem para armazenar intersecções e diferenças: SINTERSTORE e SDIFFSTORE.

SMOVE move um item de um set para outro.
SCARD (set cardinality) diz o tamanho do set.
SPOP key remove um valor aleatório.
SREM key value [value...] remove valores específicos de um set.

Não há comandos de bloqueio para sets, assim como há para listas.


### Conjuntos ordenados
São estruturas de dados ordenados como listas e com itens únicos como conjuntos. Elas possuem pares de chave-valor como hashes, mas suas chaves são números, indicando sua ordem. Por ser um conjunto ordenado, a inserção de novos itens terá um custo log(N), onde N é o tamanho do conjunto, ao contrário do tempo constante de hashes e listas.

Criando um conjunto ordenado da quantidade de visita às urls encurtadas:
`ZADD visits 500 7wks 9 gog 9999 prag`

Verificando os itens do conjunto:
`ZRANGE visits 0 -1`

Incrementando o valor de um item:
`ZINCRBY visits 1 prag`

Para decrementar usamos ZINCRBY com um valor negativo.


### Ranges
Para buscar os itens e seus scores em um conjunto ordenado usamos o comando a seguir:
`ZRANGE visits 0 -1 WITHSCORES`
1) "gog"
2) "9"
3) "7wks"
4) "500"
5) "prag"
6) "10000"

Para buscar no sentido inverso:
`ZREVRANGE visits 0 -1 WITHSCORES`
1) "prag"
2) "10000"
3) "7wks"
4) "500"
5) "gog"
6) "9"


Buscando itens por score:
`ZRANGEBYSCORE visits 9 9999` (9 <= score <= 10000)
1) "gog"
2) "7wks"

`ZRANGEBYSCORE visits (9 9999` (9 < score <= 10000)
1) "7wks"

Podemos usar valores positivos e negativos, inclusive infinitos:
`ZRANGEBYSCORE visits -inf inf`
`ZREVRANGEBYSCORE visits -inf inf`

ZREMRANGEBYRANK e ZREMRANGEBYSCORE removem os itens de um range delimitados pelo rank e score, respectivamente.

### Uniãos
Os comandos de união são uns dos mais complexos no Redis, pois devem tratar de merges de dados.

A operação de união tem o seguinte formato:
ZUNIONSTORE destination numkeys key [key ...] [WEIGHTS weight [weight ...]] [AGGREGATE SUM|MIN|MAX]

numkeys é o número de chaves que queremos unir.
weight é um número opcional para multiplicar os scores das chaves definidas. Se tivermos duas chaves podemos usar dois weigts, e assim por diante.

Salvando votos das urls encurtadas:
`ZADD votes 2 7wks 0 gog 9001 prag`

Como cada site tem um peso diferente, criaremos um conjunto com os valores finais de cada url:
`ZUNIONSTORE imp 2 visits votes WEIGHTS 1 2 AGGREGATE SUM`

Verificando o resultado:
`ZRANGEBYSCORE imp -inf inf WITHSCORES`
1) "gog"
2) "9"
3) "7wks"
4) "504"
5) "prag"
6) "28002"


Testando com o agregador MAX:
`ZUNIONSTORE imp:max 2 visits votes WEIGHTS 1 2 AGGREGATE MAX`
`ZRANGEBYSCORE imp:max -inf inf WITHSCORES`
1) "gog"
2) "9"
3) "7wks"
4) "500"
5) "prag"
6) "18002"


Caso queiramos multiplicar todos os scores de um conjunto, fazemos o seguinte:
`ZUNIONSTORE votes 1 votes WEIGHTS 2`
`ZRANGE votes 0 -1 WITHSCORES`
1) "gog"
2) "0"
3) "7wks"
4) "4"
5) "prag"
6) "18002"

Para intersections podemos usar ZINTERSTORE.


## Expiração

Para definir um tempo de expiração de uma chave usamos o comando EXPIRE e indicamos o tempo em segundos:
`SET ice "I'm melting..."`
`EXPIRE ice 10`

e checamos se a chave ainda existe com o comando EXISTS:
`EXISTS ice`

Para definir uma chave e seu tempo de vida ao mesmo tempo:
`SETEX ice 10 "I'm melting..."`

Para saber o tempo restante de vida de uma chave, usamos o TTL:
`TTL ice`

Podemos a qualquer momento remover o tempo de expiração usando PERSIST:
`PERSIST ice`

Um comando semelhante é o EXPIREAT, onde podemos definir em que momento a chave deve expirar.


## Namespaces dos bancos de dados
Nós podemos utilizar os namespaces do redis para armazenar valores diferentes para um mesmo atributo. Para uma chave greeting podemos armazenar o valor "guten Tag" em um namespace German e o valor "bonjour" em um namespace French.

Em redis um namespace é chamado database e é chaveado por um número. Até agora viemos trabalhando com o namespace 0 (database 0).

Definindo o valor hello para a chave greeting:
`SET greeting hello`
`GET greeting`

mudando de banco de dados:
`SELECT 1`
`GET greeting` (receberemos nil)

podemos definir um novo valor sem afetar o valor do banco de dados 0:
`SET greeting "guten Tag"`
`GET greeting`


Como todos os namespaces estão na mesma instância, podemos mover um valor para outro namespace:
`MOVE greeting 2`
`SELECT 2`
`GET greeting`

Redis disponibiliza os comando FLUSHDB e FLUSHALL, que removem as chaves de um banco de dados e de todos, respectivamente.


## Uso avançado, distribuição

Podemos nos comunicar com o redis através da rede TCP.
```bash
telnet localhost 6379
# Trying 127.0.0.1...
# Connected to localhost.
# Escape character is '^]'.
SET test hello
# +OK
GET test
# $5
# hello
SADD stest 1 99
# :2
SMEMBERS stest
# *2
# $1
# 1
# $2
# 99
```

### Pipelining
Podemos escrevendo comandos em sequência para enviar ao banco, lembrando sempre de finalizar cada comando com um \r\n.

```bash
(echo -en "ECHO hello\r\n"; sleep 1) | nc localhost 6379
```

```bash
(echo -en "PING\r\nPING\r\nPING\r\n"; sleep 1) | nc localhost 6379
```

#### Produtor-Consumidor
Vamos agora pegar o exemplo anterior de blocking list e alterar para publicar mensagens para mais de um consumidor. Começamos com um consumidor ouvindo uma key para receber as mensagens (a key funciona como um canal aqui).

Após entrar em dois terminais diferentes do Redis, executamos em cada um o comando abaixo:
```bash
SUBSCRIBE comments
# Reading messages... (press Ctrl-C to quit)
# 1) "subscribe"
# 2) "comments"
# 3) (integer) 1
```

Em um terceiro terminal do Redis, executamos a publicação. O comando PUBLISH retorna 2, indicando que dois consumidores receberam a mensagem:
```bash
PUBLISH comments "Check out this shortcoded site! 7wks"
# (integer) 2
```

Ambos os consumidores irão receber 3 dados: a string "message", o nome do canal e o dado enviado:
```
1) "message"
2) "comments"
3) "Check out this shortcoded site! 7wks"
```

Quando um consumidor não quiser mais receber mensagens de um canal ele pode executar o comando UNSUBSCRIBE <nome do canal>, ou executar apenas UNSUBSCRIBE para sair de todos os canais. 


## Server Info
O comando INFO é importante pois ele nos traz informações e configurações globais do servidor, como durabilidade, fragmentação da memória e status das replicas do server.


## Configurações do Redis
Algumas configurações do Redis são as seguintes:
daemonize: no
port: 6379
loglevel: verbose
logfile: stdout
database: 16

Por padrão, daemonize é definido como no, e é por isso que o servidor sempre inicializa em primeiro plano. Isso é bom para testes, mas não é recomendado para produção. Alterar este valor para yes executará o servidor em segundo plano.

A porta padrão é a porta 6379. Isso pode ser especialmente útil ao executar vários servidores Redis em uma única máquina.

loglevel é padronizado como verbose , mas é bom configurá-lo para notice ou warning em produção para reduzir o número de eventos de log. logfile imprime os dados na saída (stdout), mas um nome de arquivo é necessário se você executar no modo daemonize.

database define o número de bancos de dados Redis que temos disponíveis. Nós vimos como alternar entre bancos de dados. Se você planeja usar apenas um único banco de dados (um namespace), não é uma má ideia definir o valor 1 para evitar que bancos de dados indesejados sejam criados acidentalmente.


### Segurança
Podemos dificultar o uso de qualquer comando definindo no arquivo de configuração o seguinte:

rename-command FLUSHALL c283d93ac9528f986023793b411e4ba2

Desta forma, o comando FLUSHALL gerará um erro, mas ao executar c283d93ac9528f986023793b411e4ba2 teremos o comportamento do FLUSHALL.

Para impedir o uso de um comando, renomeamos ele para string vazia:

rename-command FLUSHALL ""

### Ajustando parâmetros
Podemos definir os parâmetros e executar um benchmark para saber o impacto dos valores. Por padrão o redis executa 10.000 requests usando 50 clientes em paralelo, mas podemos alterar o número de requests usando -n.

```bash
redis-benchmark -n 100000
# ...
# ====== MSET (10 keys) ======                                                    
#   100000 requests completed in 1.00 seconds
#   50 parallel clients
#   3 bytes payload
#   keep alive: 1
#   host configuration "save": 3600 1 300 100 60 10000
#   host configuration "appendonly": no
#   multi-thread: no
#
# Latency by percentile distribution:
# 0.000% <= 0.111 milliseconds (cumulative count 1)
# 50.000% <= 0.367 milliseconds (cumulative count 52147)
# 75.000% <= 0.455 milliseconds (cumulative count 75721)
# 87.500% <= 0.527 milliseconds (cumulative count 88413)
#   ...
```

Diversos comandos são testados.

## Replicas Master-Slave
Um servidor Redis é definido como master por padrão e os dados são replicados para qualquer número de servidores escravos.

Criamos o arquivo docker-compose-master-slave.yaml:
```yaml
version: '3.8'
services:
  redis_master:
    image: redis:7.0.10-alpine
    container_name: redis_master_database
    restart: always
    ports:
      - '6379:6379'
    volumes: 
      - redis_master_data:/data
      - ./redis.conf:/data/usr/local/etc/redis/redis.conf
    command: redis-server usr/local/etc/redis/redis.conf
    networks:
      - redis_master_slave

  redis_slave:
    image: redis:7.0.10-alpine
    container_name: redis_slave_database
    restart: always
    ports:
      - '6378:6379'
    volumes: 
      - redis_slave_data:/data
      - ./redis_s1.conf:/data/usr/local/etc/redis/redis.conf
    command: redis-server usr/local/etc/redis/redis.conf
    networks:
      - redis_master_slave

volumes:
  redis_master_data:
    driver: local
  redis_slave_data:
    driver: local

networks: 
  redis_master_slave:
    driver: bridge
```

Criamos o arquivo de configuração redis_s1.conf alterando os seguintes parâmetros:
bind redis_slave -::1
protected-mode no
port 6378
slaveof redis_master 6379

No arquivo redis.conf alteramos o seguinte:
bind redis_master -::1
protected-mode no


Após isso, executamos primeiro o serviço master e em outro terminal executamos o serviço slave.
Se tudo der certo, devemos ver algo semelhante no terminal do slave:
```bash
...
redis_slave_database | 1:S 04 Apr 2023 23:23:33.808 * Master replied to PING, replication can continue...
redis_slave_database | 1:S 04 Apr 2023 23:23:33.808 * Partial resynchronization not possible (no cached master)
redis_slave_database | 1:S 04 Apr 2023 23:23:38.607 * Full resync from master: 95ce17b65ff24fba93540b0da797ac0c0c1fe1b6:14
redis_slave_database | 1:S 04 Apr 2023 23:23:38.608 * MASTER <-> REPLICA sync: receiving streamed RDB from master with EOF to disk
redis_slave_database | 1:S 04 Apr 2023 23:23:38.608 * MASTER <-> REPLICA sync: Flushing old data
redis_slave_database | 1:S 04 Apr 2023 23:23:38.608 * MASTER <-> REPLICA sync: Loading DB in memory
redis_slave_database | 1:S 04 Apr 2023 23:23:38.615 * Loading RDB produced by version 7.0.10
redis_slave_database | 1:S 04 Apr 2023 23:23:38.615 * RDB age 0 seconds
redis_slave_database | 1:S 04 Apr 2023 23:23:38.615 * RDB memory usage when created 0.91 Mb
redis_slave_database | 1:S 04 Apr 2023 23:23:38.615 * Done loading RDB, keys loaded: 0, keys expired: 0.
redis_slave_database | 1:S 04 Apr 2023 23:23:38.615 * MASTER <-> REPLICA sync: Finished with success
```
E no terminal do master:
```bash
...
redis_master_database | 15:C 04 Apr 2023 23:23:38.608 * Fork CoW for RDB: current 0 MB, peak 0 MB, average 0 MB
redis_master_database | 1:M 04 Apr 2023 23:23:38.608 # Diskless rdb transfer, done reading from pipe, 1 replicas still up.
redis_master_database | 1:M 04 Apr 2023 23:23:38.615 * Background RDB transfer terminated with success
redis_master_database | 1:M 04 Apr 2023 23:23:38.615 * Streamed RDB transfer with replica 192.168.112.3:6380 succeeded (socket). Waiting for REPLCONF ACK from slave to enable streaming
redis_master_database | 1:M 04 Apr 2023 23:23:38.615 * Synchronization with replica 192.168.112.3:6380 succeeded
```

Para entrar no cli do redis, usamos agora o seguinte comando:
`redis-cli -h redis_master -p 6379:6379` (para entrar no cli do master)
`redis-cli -h redis_slave -p 6378:6378` (para entrar no cli do slave)

Ao salvar algum dado no server master:
`SADD meetings "StarTrek Pastry Chefs" "LARPers Intl."`

podemos consultar no slave, pois os dados foram replicados:
`SMEMBERS meetings`


## Data Dump




Trabalhando com mais de um banco de dados:
- https://pierreabreu.medium.com/building-redis-cluster-with-docker-compose-9569ddb6414a

