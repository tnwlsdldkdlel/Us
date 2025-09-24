export type CalendarDay = {
  date: Date;
  isCurrentMonth: boolean;
};

export function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

export function isSameDay(a: Date, b: Date): boolean {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

export function buildMonthMatrix(baseDate: Date): CalendarDay[][] {
  const year = baseDate.getFullYear();
  const month = baseDate.getMonth();

  const firstOfMonth = new Date(year, month, 1);
  const startWeekday = firstOfMonth.getDay();

  const days: CalendarDay[][] = [];
  let current = new Date(year, month, 1 - startWeekday);

  for (let week = 0; week < 6; week += 1) {
    const row: CalendarDay[] = [];
    for (let day = 0; day < 7; day += 1) {
      row.push({
        date: new Date(current),
        isCurrentMonth: current.getMonth() === month,
      });
      current.setDate(current.getDate() + 1);
    }
    days.push(row);
  }

  return days;
}
