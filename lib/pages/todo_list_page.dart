import 'package:flutter/material.dart';
import 'package:projeto02_todo_list/models/todo.dart';
import 'package:projeto02_todo_list/repositories/todo_repository.dart';
import 'package:projeto02_todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: todoController,
                        decoration: InputDecoration(
                          hintText: 'Estudar Flutter',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: const OutlineInputBorder(),
                          errorText: errorText,
                          errorStyle: const TextStyle(
                            color: Colors.red,
                          ),
                          label: const Text('Adicione uma tarefa'),
                          labelStyle: const TextStyle(
                            color: Colors.deepPurpleAccent,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.indigo,
                              width: 2,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.all(17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        String text = todoController.text;
                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'A tarefa não pode ser vazia!';
                          });
                          return; // Para finalizar o bloco de código onPressed.
                        }

                        Todo newTodo = Todo(
                          title: text,
                          dateTime: DateTime.now(),
                        );
                        setState(() {
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoRepository.saveTodoList(todos);
                        todoController.clear();
                      },
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 15),
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Você possui ${todos.length} tarefas pendentes'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: showDeleteTodosConfirmationDiolog,
                      child: const Text(
                        'Limpar tudo',
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });

    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} removida com sucesso',
          style: const TextStyle(
            color: Colors.deepPurpleAccent,
          ),
        ),
        backgroundColor: Colors.amber,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.deepPurpleAccent,
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeleteTodosConfirmationDiolog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text('Limpar tudo?'),
        content:
            const Text('Você tem certez que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.indigo,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
