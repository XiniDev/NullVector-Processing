import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

class Graph<T> {

    Map<T, List<T>> adjacencyList;

    public Graph() {
        adjacencyList = new HashMap<>();
    }

    public void addNode(T node) {
        adjacencyList.putIfAbsent(node, new ArrayList<>());
    }

    public void addEdge(T from, T to) {
        if (!adjacencyList.containsKey(from) || !adjacencyList.containsKey(to)) {
            return;
        }

        adjacencyList.get(from).add(to);
        adjacencyList.get(to).add(from);
    }

    public void removeEdge(T from, T to) {
        if (!adjacencyList.containsKey(from) || !adjacencyList.containsKey(to)) {
            return;
        }

        adjacencyList.get(from).remove(to);
        adjacencyList.get(to).remove(from);
    }

    public List<T> getNeighbors(T node) {
        return adjacencyList.getOrDefault(node, new ArrayList<>());
    }

    public Set<T> getNodes() {
        return adjacencyList.keySet();
    }
}