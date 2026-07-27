# nes-build-workflow Specification

## Purpose

定义 Spring Framework 6.2 NES 的 Make 构建、验证、本地安装与 Nexus 发布入口。

## Requirements

### Requirement: Make 构建入口

项目 MUST 提供 `make test`、`make build-thin`、`make install` 和 `make deploy`，并通过 Gradle wrapper 执行。

#### Scenario: 默认使用 Corretto 17

- **WHEN** 执行 `make test` 或 `make build-thin`
- **THEN** 使用 `JDK17` 指向的 Amazon Corretto 17

#### Scenario: 默认 Gradle 用户目录

- **WHEN** 执行 `make test` 或 `make deploy`
- **THEN** 使用默认 `~/.gradle` 作为 Gradle 缓存与全局配置目录

### Requirement: 验证门禁

NES GAV change 实施完成后 MUST 通过 `make build-thin` 与 `make test`。

#### Scenario: build-thin 验证 manifest

- **WHEN** `make build-thin` 成功
- **THEN** `spring-core` JAR 的 `Implementation-Version` 为 `6.2.19`

### Requirement: 测试与构建文档

`doc/TESTING.md` MUST 描述测试环境、命令与 TDD 约定；`doc/QUICK_START.md` MUST 描述 `build-thin` 与 `install` 的最小使用路径。

#### Scenario: 新成员上手

- **WHEN** 阅读 `doc/QUICK_START.md`
- **THEN** 可在 5 分钟内完成构建或测试命令准备
