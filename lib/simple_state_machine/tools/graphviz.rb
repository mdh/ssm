module SimpleStateMachine
  module Tools
    require 'cgi'
    module Graphviz
      # Graphviz dot format for rendering as a directional graph
      def to_graphviz_dot
        "digraph G {\n" +
          transitions.map { |t| t.to_graphviz_dot }.sort.join(";\n") +
          "\n}"
      end

      # Generates a url that renders states and events as a directional graph.
      # See http://code.google.com/apis/chart/docs/gallery/graphviz.html
      def google_chart_url
        graph = transitions.map { |t| t.to_graphviz_dot }.sort.join(";")
        puts graph
        "http://chart.googleapis.com/chart?cht=gv&chl=digraph{#{::CGI.escape graph}}"
      end
    end
  end
end
