# 白色凤眼兔 tkinter MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用 Python 标准库构建可运行的白色凤眼兔桌面宠物，提供五项长期属性、幼儿园课程、日常互动和本地存档。

**Architecture:** `domain.py` 保持纯业务逻辑，`repository.py` 只处理 JSON 档案，`store.py` 负责状态变更与持久化，`app.py` 只组合 tkinter 窗口和视图。课程与互动通过事件更新档案，UI 不直接修改数值。

**Tech Stack:** Python 3、tkinter、json、dataclasses、unittest。

---

## 文件结构

```
src/momo_pet/
  __init__.py
  domain.py        # 属性、档案、课程和事件 reducer
  repository.py    # 原子 JSON 存档和损坏档案备份
  store.py         # 内存状态、事件分发和存档
  app.py           # tkinter 桌宠窗口和学堂面板
  __main__.py      # python3 -m momo_pet 启动入口
tests/
  test_domain.py
  test_repository.py
  test_store.py
README.md
```

### Task 1: 建立 Python 包并定义五项属性

**Files:**
- Create: `src/momo_pet/__init__.py`
- Create: `tests/test_domain.py`
- Create: `src/momo_pet/domain.py`

- [ ] **Step 1: 写入失败的属性上限测试**

```python
from momo_pet.domain import Stat

def test_stat_clamps_value_to_zero_through_one_hundred():
    assert Stat(105).value == 100
    assert Stat(-1).value == 0
```

- [ ] **Step 2: 验证测试因模块不存在而失败**

Run: `PYTHONPATH=src python3 -m unittest tests.test_domain -v`

Expected: `ModuleNotFoundError: No module named 'momo_pet.domain'`。

- [ ] **Step 3: 实现最小属性值对象**

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Stat:
    value: int
    def __post_init__(self):
        object.__setattr__(self, "value", max(0, min(100, self.value)))
```

- [ ] **Step 4: 验证测试通过**

Run: `PYTHONPATH=src python3 -m unittest tests.test_domain -v`

Expected: `test_stat_clamps_value_to_zero_through_one_hundred` PASS。

### Task 2: 实现宠物档案、课程和事件 reducer

**Files:**
- Modify: `src/momo_pet/domain.py`
- Modify: `tests/test_domain.py`

- [ ] **Step 1: 写入识字课程奖励测试**

```python
from momo_pet.domain import Course, PetEvent, PetProfile, reduce_event

def test_literacy_raises_intelligence_and_creativity():
    profile = reduce_event(PetProfile(), PetEvent.course_completed(Course.LITERACY))
    assert profile.intelligence.value == 8
    assert profile.creativity.value == 4
    assert profile.energy.value == 72
```

- [ ] **Step 2: 运行测试并确认失败**

Run: `PYTHONPATH=src python3 -m unittest tests.test_domain -v`

Expected: 导入或 `course_completed` 缺失。

- [ ] **Step 3: 实现档案和 reducer**

```python
class Course(Enum): LITERACY = "literacy"; JUMPING = "jumping"; STAGE = "stage"
@dataclass(frozen=True)
class PetProfile:
    hunger: Stat = Stat(80); mood: Stat = Stat(80); cleanliness: Stat = Stat(80); energy: Stat = Stat(80)
    intelligence: Stat = Stat(0); strength: Stat = Stat(0); charm: Stat = Stat(0); creativity: Stat = Stat(0); courage: Stat = Stat(0)
    kindergarten_xp: int = 0
```

`reduce_event` 必须实现喂食、抚摸、休息、三门课程和最多三天的离线恢复；识字提高智力/创造力，跳跳提高武力/勇气，舞台提高魅力/勇气。

- [ ] **Step 4: 验证领域测试**

Run: `PYTHONPATH=src python3 -m unittest tests.test_domain -v`

Expected: 所有领域测试 PASS。

### Task 3: 实现本地 JSON 存档

**Files:**
- Create: `src/momo_pet/repository.py`
- Create: `tests/test_repository.py`

- [ ] **Step 1: 写入存档往返测试**

```python
def test_save_then_load_returns_same_profile(tmp_path):
    repository = PetRepository(tmp_path / "pet.json")
    expected = PetProfile(intelligence=Stat(12))
    repository.save(expected)
    assert repository.load() == expected
```

- [ ] **Step 2: 运行测试并确认失败**

Run: `PYTHONPATH=src python3 -m unittest tests.test_repository -v`

Expected: `ImportError`，因为 `PetRepository` 不存在。

- [ ] **Step 3: 实现 JSON 编解码与损坏档案备份**

`PetRepository.save` 必须写入临时文件后 `replace`；`load` 解析失败时，把原文件移动为 `.corrupt` 并抛出 `CorruptSaveError`。

- [ ] **Step 4: 验证存档测试**

Run: `PYTHONPATH=src python3 -m unittest tests.test_repository -v`

Expected: 往返和损坏档案测试 PASS。

### Task 4: 连接 store 与 tkinter 学堂面板

**Files:**
- Create: `src/momo_pet/store.py`
- Create: `tests/test_store.py`
- Create: `src/momo_pet/app.py`
- Create: `src/momo_pet/__main__.py`

- [ ] **Step 1: 写入分发测试**

```python
def test_dispatch_petted_updates_mood_and_saves(tmp_path):
    store = PetStore(PetProfile(), PetRepository(tmp_path / "pet.json"))
    store.dispatch(PetEvent.petted())
    assert store.profile.mood.value == 92
```

- [ ] **Step 2: 运行测试并确认失败**

Run: `PYTHONPATH=src python3 -m unittest tests.test_store -v`

Expected: `ImportError`，因为 `PetStore` 不存在。

- [ ] **Step 3: 实现 store 与应用窗口**

`PetStore.dispatch` 必须调用 `reduce_event`、更新 `profile` 并立即存档。`PetApp` 必须创建无边框、置顶、可拖动的白色凤眼兔浮窗；点击“学堂”打开面板，显示五项属性和三门课程按钮。

- [ ] **Step 4: 验证完整测试与人工启动**

Run: `PYTHONPATH=src python3 -m unittest discover -s tests -v && PYTHONPATH=src python3 -m momo_pet`

Expected: 所有单元测试 PASS；出现可拖动兔子窗口，课程按钮实时改变属性，关闭后重新打开保留数据。

## 自检结果

- 包含五项长期属性、四项日常状态、幼儿园三课、离线恢复、本地 JSON 存档、桌面浮窗和学堂面板。
- 仅用标准库，避免了当前环境缺少 Xcode 和第三方依赖的问题。
- 领域逻辑和存档可独立测试，tkinter 只承担显示与用户输入。

