pragma solidity ^0.4.25;

/**
    ================================
    Disclaimer: Данный контракт - всего лишь игра и не является профессиональным инструментом заработка.
    Отнеситесь к этому с забавой, пользуйтесь с умом и не забывайте, что вклад денег в фаст-контракты - это всегда крайне рисково. 
    Мы не призываем людей относится к данному контракту, как к инвестиционному проекту.
    ================================

  Gradual.pro - Плавно растущий и долго живущий умножитель КАЖДЫЙ ДЕНЬ с розыгрыванием ДЖЕКПОТА!, который возвращает 121% от вашего депозита!

  Маленький лимит на депозит избавляет от проблем с КИТАМИ, которые очень сильно тормозили предыдущую версию контракта и значительно продлевает срок его жизни!

  Автоматические выплаты!
  Полные отчеты о потраченых на рекламу средствах в группе!
  Без ошибок, дыр, автоматический - для выплат НЕ НУЖНА администрация!
  Создан и проверен профессионалами!
  Код полностью документирован на русском языке, каждая строчка понятна!

  Вебсайт: http://gradual.pro/
  Канал в телеграмме: https://t.me/gradualpro

  1. Пошлите любую ненулевую сумму на адрес контракта
     - сумма от 0.01 до 1 ETH
     - gas limit минимум 250000
     - вы встанете в очередь
  2. Немного подождите
  3. ...
  4. PROFIT! Вам пришло 121% от вашего депозита.
  5. После 21:00 МСК контракт выплачивает 25% от накопленного джекпота последнему вкладчику.
  6. Остальной джекпот распределяется всем остальным в обратной очереди по 121% от каждого вклада.
  7. Затем очередь обнуляется и запускается заново!


  Как это возможно?
  1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
     новых инвесторов до тех пор, пока не получит 121% от своего депозита
  2. Выплаты могут приходить несколькими частями или все сразу
  3. Как только вы получаете 121% от вашего депозита, вы удаляетесь из очереди
  4. Вы можете делать несколько депозитов сразу
  5. Баланс этого контракта состовляет сумму джекпота на данный момент!

     Таким образом, последние платят первым, и инвесторы, достигшие выплат 121% от депозита,
     удаляются из очереди, уступая место остальным

              новый инвестор --|            совсем новый инвестор --|
                 инвестор5     |                новый инвестор      |
                 инвестор4     |     =======>      инвестор5        |
                 инвестор3     |                   инвестор4        |
 (част. выплата) инвестор2    = FIRST_START_TIMESTAMP, "Not started yet!");

        // Проверяем минимальный лимит газа, иначе отменяем депозит и возвращаем деньги вкладчику
        require(gasleft() >= MINIMAL_GAS_LIMIT, "We require more gas!");

        // Проверяем максимальную сумму вклада
        require(msg.value <= MAX_LIMIT, "Deposit is too big!");

        // Проверяем минимальную сумму вклада
        require(msg.value >= MIN_LIMIT, "Deposit is too small!");

        // Проверяем, если нужно сделать рестарт
        if (now >= lastStartTimestamp + RESTART_INTERVAL) {
            // Записываем время нового рестарта
            lastStartTimestamp += (now - lastStartTimestamp) / RESTART_INTERVAL * RESTART_INTERVAL;
            // Выплачиваем Джекпот
            _payoutJackpot();
            _clearQueue();
            // Вызываем событие
            emit Restart(now);
        }

        // Добавляем депозит в очередь, записываем что ему нужно выплатить % от суммы депозита
        _insertQueue(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * MULTIPLIER / 100)));

        // Увеличиваем Джекпот
        jackpotAmount += msg.value * JACKPOT_PERCENT / 100;

        // Отправляем процент на продвижение проекта
        uint ads = msg.value * ADS_PERCENT / 100;
        ADS_SUPPORT.transfer(ads);

        // Отправляем процент на техническую поддержку проекта
        uint tech = msg.value * TECH_PERCENT / 100;
        TECH_SUPPORT.transfer(tech);

        // Вызываем функцию оплаты первым в очереди депозитам
        _pay();
    }

    // Функция используется для оплаты первым в очереди депозитам
    // Каждая новая транзация обрабатывает от 1 до 4+ вкладчиков в начале очереди 
    // В зависимости от оставшегося газа
    function _pay() private {
        // Попытаемся послать все деньги имеющиеся на контракте первым в очереди вкладчикам за вычетом суммы Джекпота
        uint128 money = uint128(address(this).balance) - uint128(jackpotAmount);

        // Проходим по всей очереди
        for (uint i = 0; i < queueCurrentLength; i++) {

            // Достаем номер первого в очереди депозита
            uint idx = currentReceiverIndex + i;

            // Достаем информацию о первом депозите
            Deposit storage dep = _queue[idx];

            // Если у нас есть достаточно денег для полной выплаты, то выплачиваем ему все
            if(money >= dep.expect) {
                // Отправляем ему деньги
                dep.depositor.transfer(dep.expect);
                // Обновляем количество оставшихся денег
                money -= dep.expect;
            } else {
                // Попадаем сюда, если у нас не достаточно денег выплатить все, а лишь часть
                // Отправляем все оставшееся
                dep.depositor.transfer(money);
                // Обновляем количество оставшихся денег
                dep.expect -= money;
                // Выходим из цикла
                break;
            }

            // Проверяем если еще остался газ, и если его нет, то выходим из цикла
            if (gasleft() <= 50000) {
                //  Следующий вкладчик осуществит выплату следующим в очереди
                break;
            }
        }

        // Обновляем номер депозита ставшего первым в очереди
        currentReceiverIndex += i;
    }

    function _payoutJackpot() private {
        // Попытаемся послать все деньги имеющиеся на контракте первым в очереди вкладчикам за вычетом суммы Джекпота
        uint128 money = uint128(jackpotAmount);

        // Перечисляем 25% с джекпота победителю
        Deposit storage dep = _queue[queueCurrentLength - 1];

        dep.depositor.transfer(uint128(jackpotAmount * JACKPOT_WINNER_PERCENT / 100));
        money -= uint128(jackpotAmount * JACKPOT_WINNER_PERCENT / 100);

        // Проходим по всей очереди с конца
        for (uint i = queueCurrentLength - 2; i < queueCurrentLength && i >= currentReceiverIndex; i--) {
            // Достаем информацию о последнем депозите
            dep = _queue[i];

            // Если у нас есть достаточно денег для полной выплаты, то выплачиваем ему все
            if(money >= dep.expect) {
                // Отправляем ему деньги
                dep.depositor.transfer(dep.expect);
                // Обновляем количество оставшихся денег
                money -= dep.expect;
            } else if (money > 0) {
                // Попадаем сюда, если у нас не достаточно денег выплатить все, а лишь часть
                // Отправляем все оставшееся
                dep.depositor.transfer(money);
                // Обновляем количество оставшихся денег
                dep.expect -= money;
                money = 0;
            } else {
                break;
            }
        }

        // Обнуляем джекпот на новый раунд
        jackpotAmount = 0;
        // Обнуляем очередь
        currentReceiverIndex = 0;
    }

    function _insertQueue(Deposit deposit) private {
        if (queueCurrentLength == _queue.length) {
            _queue.length += 1;
        }
        _queue[queueCurrentLength++] = deposit;
    }

    function _clearQueue() private {
        queueCurrentLength = 0;
    }

    // Показывает информацию о депозите по его номеру (idx), можно следить в разделе Read contract
    // Вы можете получить номер депозита  (idx) вызвав функцию getDeposits()
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = _queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    // Показывает количество вкладов определенного инвестора
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i < queueCurrentLength; ++i){
            if(_queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    // Показывает все депозиты (index, deposit, expect) определенного инвестора, можно следить в разделе Read contract
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i = currentReceiverIndex; i < queueCurrentLength; ++i){
                Deposit storage dep = _queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }
    
    // Показывает длинну очереди, можно следить в разделе Read contract
    function getQueueLength() public view returns (uint) {
        return queueCurrentLength - currentReceiverIndex;
    }

}