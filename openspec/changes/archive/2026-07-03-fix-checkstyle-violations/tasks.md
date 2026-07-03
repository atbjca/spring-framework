## 1. spring-core 模块修复

- [x] 1.1 修复 ResourceUtils.java checkstyle 违规
- [x] 1.2 修复 StringUtils.java checkstyle 违规
- [x] 1.3 修复 StringToBooleanConverter.java checkstyle 违规
- [x] 1.4 验证 `./gradlew :spring-core:checkstyleMain` 通过

## 2. spring-beans 模块修复

- [x] 2.1 修复 PropertyComparator.java checkstyle 违规
- [x] 2.2 验证 `./gradlew :spring-beans:checkstyleMain` 通过

## 3. spring-context 模块修复

- [x] 3.1 修复 CronField.java checkstyle 违规
- [x] 3.2 修复 DataBinder.java checkstyle 违规
- [x] 3.3 修复 DataBinderTests.java checkstyle 违规
- [x] 3.4 验证 `./gradlew :spring-context:checkstyleMain :spring-context:checkstyleTest` 通过

## 4. spring-expression 模块修复

- [x] 4.1 修复 SpelParserConfiguration.java checkstyle 违规
- [x] 4.2 修复 TypeReference.java checkstyle 违规
- [x] 4.3 修复 InternalSpelExpressionParser.java checkstyle 违规
- [x] 4.4 修复 Tokenizer.java checkstyle 违规
- [x] 4.5 验证 `./gradlew :spring-expression:checkstyleMain` 通过

## 5. spring-jdbc 模块修复

- [x] 5.1 修复 CallMetaDataContext.java checkstyle 违规
- [x] 5.2 修复 Db2CallMetaDataProvider.java checkstyle 违规
- [x] 5.3 修复 GenericCallMetaDataProvider.java checkstyle 违规
- [x] 5.4 修复 GenericTableMetaDataProvider.java checkstyle 违规
- [x] 5.5 修复 TableMetaDataContext.java checkstyle 违规
- [x] 5.6 修复 SqlParameterSourceUtils.java checkstyle 违规
- [x] 5.7 修复 AbstractJdbcInsert.java checkstyle 违规
- [x] 5.8 验证 `./gradlew :spring-jdbc:checkstyleMain :spring-jdbc:checkstyleTest` 通过

## 6. 其他模块修复

- [x] 6.1 修复 spring-jms: JmsListenerContainerParser.java、MappingJackson2MessageConverter.java
- [x] 6.2 修复 spring-context-support: LocalDataSourceJobStore.java
- [x] 6.3 修复 spring-test: NestedTestConfiguration.java、TestConstructor.java
- [x] 6.4 修复 spring-web: ByteArrayHttpMessageConverter.java
- [x] 6.5 修复 spring-webflux: PathResourceLookupFunction.java、ResourceWebHandler.java
- [x] 6.6 修复 spring-webmvc: PathResourceLookupFunction.java、ResourceHttpRequestHandler.java
- [x] 6.7 修复 spring-websocket: AbstractWebSocketSession.java
- [x] 6.8 验证所有模块 checkstyle 通过

## 7. Makefile 与验证

- [x] 7.1 Makefile 新增 `checkstyle` 目标
- [x] 7.2 Makefile 新增 `format` 目标
- [x] 7.3 `make build` 全量构建通过
