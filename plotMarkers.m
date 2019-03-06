function plotMarkers(markers, symbol)
%figure;
plot3(markers(:, 1), markers(:, 2), markers(:, 3), symbol, 'LineWidth', 3);
axis equal;
xlabel('x'); ylabel('y'); zlabel('z');
end
